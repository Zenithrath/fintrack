import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'recap_page.dart'; // Pastikan file ini ada

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = true;
  bool isLoading = false;
  String? selectedCategory;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final firestoreService = FirestoreService();
  final authService = AuthService();
  final _currencyFormat = NumberFormat('#,##0', 'id_ID');

  Stream<List<TransactionRecord>>? transactionStream;
  Future<Map<String, double>>? monthlyStatsFuture;

  final List<String> expenseCategories = [
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills",
    "Health",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final user = authService.currentUser;
    if (user != null) {
      transactionStream = firestoreService.getTransactionsByUserStream(
        user.uid,
      );
      monthlyStatsFuture = firestoreService.getMonthlyStats(
        user.uid,
        DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final user = authService.currentUser;
    if (user == null) return;
    if (amountController.text.isEmpty) {
      _showSnack("Isi nominal dulu ya", Colors.orange);
      return;
    }
    if (!isIncome && selectedCategory == null) {
      _showSnack("Pilih kategori expense dulu", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      String cleanAmount = amountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      double amount = double.parse(cleanAmount);
      if (amount <= 0) throw Exception("Nominal harus lebih dari 0");

      String finalCategory = isIncome ? "Income" : selectedCategory!;

      final newTransaction = TransactionRecord(
        userId: user.uid,
        title: finalCategory,
        amount: amount,
        category: finalCategory,
        date: DateTime.now(),
        description: noteController.text.trim(),
        type: isIncome ? 'income' : 'expense',
      );

      await firestoreService.addTransaction(newTransaction);

      if (mounted) {
        _showSnack("Transaksi berhasil!", Colors.green);
        amountController.clear();
        noteController.clear();
        setState(() {
          selectedCategory = null;
          monthlyStatsFuture = firestoreService.getMonthlyStats(
            user.uid,
            DateTime.now(),
          );
        });
      }
    } catch (e) {
      if (mounted) _showSnack("Gagal simpan: $e", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _onAmountChanged(String value) {
    if (value.isEmpty) return;
    String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return;
    double numVal = double.parse(clean);
    String newText = _currencyFormat.format(numVal);
    amountController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgRed = Color(0xFF8B1D2F);
    const Color bgDarkRed = Color(0xFF570F1A);
    const Color activeGreen = Color(0xFF98FB98);
    const Color activeGreenBtn = Color(0xFF66DAA4);
    const Color activeRed = Color(0xFFFFB4B4);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgRed, bgDarkRed],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Wallet",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Personal Finance Tracker",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                FutureBuilder<Map<String, double>>(
                  future: monthlyStatsFuture,
                  builder: (context, snapshot) {
                    double balance = 0, income = 0, expense = 0;
                    if (snapshot.hasData) {
                      balance = snapshot.data!['balance'] ?? 0;
                      income = snapshot.data!['income'] ?? 0;
                      expense = snapshot.data!['expense'] ?? 0;
                    }
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Total Balance",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Rp ${_currencyFormat.format(balance)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildStatBox(
                                "Income",
                                income,
                                activeGreen,
                                Colors.green.shade800,
                              ),
                              const SizedBox(width: 12),
                              _buildStatBox(
                                "Expenses",
                                expense,
                                activeRed,
                                Colors.red.shade900,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Transaction",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isIncome = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? activeGreenBtn
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "Add Income",
                                style: TextStyle(
                                  color: isIncome ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isIncome = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isIncome
                                  ? activeGreenBtn
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "Add Expense",
                                style: TextStyle(
                                  color: !isIncome ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Amount"),
                      TextField(
                        controller: amountController,
                        onChanged: _onAmountChanged,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecor("Rp 000000"),
                      ),
                      const SizedBox(height: 16),
                      if (!isIncome) ...[
                        _buildLabel("Category"),
                        GestureDetector(
                          onTap: () => _showCategoryPicker(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedCategory ?? "Select category",
                              style: TextStyle(
                                color: selectedCategory == null
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: selectedCategory == null
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildLabel("Note (Optional)"),
                      TextField(
                        controller: noteController,
                        decoration: _inputDecor("Add a note..."),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeGreenBtn,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isIncome ? "Add Income" : "Add Expenses",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // HISTORY SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Transaction History",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      // NAVIGASI KE RECAP PAGE
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecapPage(),
                        ),
                      ),
                      child: const Text(
                        "View All",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                StreamBuilder<List<TransactionRecord>>(
                  stream: transactionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(
                        "STREAM ERROR: ${snapshot.error}",
                      ); // CEK DEBUG CONSOLE UNTUK LINK INDEX
                      return const Text(
                        "Error (Cek Debug Console)",
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    final transactions = snapshot.data ?? [];
                    if (transactions.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No transactions yet",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Start by adding your first transaction\nabove",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: transactions.take(3).map((t) {
                          final isInc = t.type == 'income';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isInc
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  child: Icon(
                                    isInc
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isInc ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM').format(t.date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  (isInc ? "+ " : "- ") +
                                      "Rp ${_currencyFormat.format(t.amount)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isInc ? Colors.green : bgRed,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 150,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(
    String title,
    double value,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Rp ${NumberFormat.compact(locale: 'id').format(value)}",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: expenseCategories.map((cat) {
                  return ActionChip(
                    label: Text(cat),
                    backgroundColor: Colors.grey[100],
                    onPressed: () {
                      setState(() => selectedCategory = cat);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
