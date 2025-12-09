import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'package:fintrack/models/user_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== USER OPERATIONS =====
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // ===== TRANSACTION OPERATIONS =====

  // 1. Add
  Future<String> addTransaction(TransactionRecord transaction) async {
    try {
      final docRef = await _firestore
          .collection('transactions')
          .add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      print("ERROR FIRESTORE ADD: $e");
      rethrow;
    }
  }

  // 2. Update
  Future<void> updateTransaction(
    String transactionId,
    TransactionRecord transaction,
  ) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update(transaction.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // 3. Delete
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // 4. Get All (STREAM) - Untuk Realtime Home Page
  Stream<List<TransactionRecord>> getTransactionsByUserStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionRecord.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // 5. Get All (FUTURE) - Untuk Profile Page (Hitung Saldo Total)
  Future<List<TransactionRecord>> getTransactionsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // 6. Get By Date Range (Untuk Recap Page)
  Future<List<TransactionRecord>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where(
            'date',
            isGreaterThanOrEqualTo: startDate,
            isLessThanOrEqualTo: endDate,
          )
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // 7. Get Stats (Logic Income - Expense)
  Future<Map<String, double>> getMonthlyStats(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      double totalIncome = 0;
      double totalExpense = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = (data['type'] ?? 'expense').toString().toLowerCase();

        if (type == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } catch (e) {
      print('Error getMonthlyStats: $e');
      return {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
