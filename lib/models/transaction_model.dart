class TransactionRecord {
  final String? id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String type; // 'income' or 'expense'

  TransactionRecord({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.type,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
      'type': type,
    };
  }

  // Create from Firestore document
  factory TransactionRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionRecord(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      description: map['description'],
      type: map['type'] ?? 'expense',
    );
  }
}
