# Firebase Backend Setup untuk Fintrack

## ✅ Yang Sudah Disetup

### 1. **Firestore Database**
- Cloud Firestore sudah ditambahkan ke pubspec.yaml
- Dependencies yang compatible sudah installed

### 2. **Services Layer**
Sudah dibuat 3 service file untuk handle backend logic:

#### a. **FirestoreService** (`lib/services/firestore_service.dart`)
Main service untuk semua operasi Firestore:
- **User Operations**
  - `createUser()` - Create user document
  - `getUser()` - Get user profile
  - `updateUser()` - Update user profile

- **Transaction Operations**
  - `addTransaction()` - Add new transaction
  - `updateTransaction()` - Update transaction
  - `deleteTransaction()` - Delete transaction
  - `getTransactionsByUser()` - Get all user transactions
  - `getTransactionsByUserStream()` - Real-time transaction updates
  - `getTransactionsByCategory()` - Filter by category
  - `getTransactionsByDateRange()` - Filter by date range
  - `getMonthlyStats()` - Get income/expense summary

#### b. **AuthService** (`lib/services/auth_service.dart`)
Handle authentication:
- `register()` - Register user baru
- `login()` - Login user
- `logout()` - Logout
- `getUserProfile()` - Get user profile dari Firestore
- `updateUserProfile()` - Update user profile
- `resetPassword()` - Reset password
- `authStateChanges` - Stream untuk auth state changes

#### c. **Models**
- **UserModel** (`lib/models/user_model.dart`) - User data structure
- **TransactionModel** (`lib/models/transaction_model.dart`) - Transaction data structure

## 📊 Firestore Database Structure

```
users/
├── {uid}/
│   ├── uid: string
│   ├── email: string
│   ├── displayName: string
│   ├── photoUrl: string (optional)
│   └── createdAt: timestamp

transactions/
├── {documentId}/
│   ├── userId: string
│   ├── title: string
│   ├── amount: double
│   ├── category: string
│   ├── date: timestamp
│   ├── description: string (optional)
│   └── type: string ('income' | 'expense')
```

## 🚀 Cara Menggunakan

### 1. **Register User**
```dart
import 'package:fintrack/services/auth_service.dart';

final authService = AuthService();
await authService.register(
  'user@example.com',
  'password123',
  'John Doe'
);
```

### 2. **Login**
```dart
await authService.login('user@example.com', 'password123');
```

### 3. **Add Transaction**
```dart
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/models/transaction_model.dart';

final firestoreService = FirestoreService();
final userId = authService.currentUser?.uid ?? '';

final transaction = Transaction(
  userId: userId,
  title: 'Gaji Bulanan',
  amount: 5000000,
  category: 'Gaji',
  date: DateTime.now(),
  description: 'Gaji dari perusahaan',
  type: 'income'
);

final docId = await firestoreService.addTransaction(transaction);
```

### 4. **Get All Transactions (Real-time)**
```dart
// Listen untuk real-time updates
final userId = authService.currentUser?.uid ?? '';
firestoreService.getTransactionsByUserStream(userId).listen((transactions) {
  setState(() {
    this.transactions = transactions;
  });
});
```

### 5. **Get Monthly Stats**
```dart
final stats = await firestoreService.getMonthlyStats(userId, DateTime.now());
print('Income: ${stats['income']}');
print('Expense: ${stats['expense']}');
print('Balance: ${stats['balance']}');
```

## 🔐 Firebase Security Rules

Tambahkan ke Firebase Console:

```json
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - user hanya bisa akses dokumen miliknya sendiri
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Transactions collection - user hanya bisa akses transaction miliknya
    match /transactions/{document=**} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## 📝 Next Steps

1. Update login_page.dart untuk pakai AuthService
2. Update signup_page.dart untuk pakai AuthService
3. Update add_transaction_page.dart untuk pakai FirestoreService
4. Update home_page.dart untuk display transactions dengan real-time updates
5. Tambahkan error handling dan loading states
6. Setup Firebase Cloud Functions untuk operasi kompleks (optional)

## 💡 Tips

- Selalu handle errors dengan try-catch
- Gunakan Stream untuk real-time data yang sering berubah
- Gunakan Future untuk operasi sekali jalan
- Always check if user is authenticated sebelum perform operations
- Setup indexes di Firestore untuk queries yang complex

---

Backend setup sudah complete! Tinggal integrate ke UI pages 🎉
