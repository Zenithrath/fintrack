import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/models/transaction_model.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = true;
  bool isLoading = false;

  // Kontroler form
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final firestoreService = FirestoreService();
  final authService = AuthService();

  // Category
  String? selectedCategory;
  final List<String> categories = [
    "Transportation",
    "Food",
    "Lifestyle",
    "Others",
  ];

  // Data dari Firestore
  final List<TransactionRecord> transactions = [];

  // Totals
  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  final _currencyFormat = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Load transactions from Firestore
  void _loadTransactions() {
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      _showSnack("User not authenticated");
      return;
    }

    firestoreService.getTransactionsByUserStream(userId).listen((newTransactions) {
      if (mounted) {
        setState(() {
          transactions.clear();
          transactions.addAll(newTransactions);
          _calculateTotals();
        });
      }
    }, onError: (error) {
      _showSnack("Error loading transactions: $error");
    });
  }

  // Calculate totals
  void _calculateTotals() {
    totalIncome = 0;
    totalExpense = 0;
    totalBalance = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    totalBalance = totalIncome - totalExpense;
  }

  String _formatCurrency(double value) {
    return "Rp ${_currencyFormat.format(value)}";
  }

  void _addTransaction() async {
    final raw = amountController.text.trim();
    if (raw.isEmpty) {
      _showSnack("Isi amount terlebih dahulu");
      return;
    }

    // Coba parse angka (hapus non-digit)
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(cleaned) ?? 0.0;
    if (amount <= 0) {
      _showSnack("Masukkan jumlah yang valid (> 0)");
      return;
    }
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      _showSnack("Pilih category terlebih dahulu");
      return;
    }

    final userId = authService.currentUser?.uid;
    if (userId == null) {
      _showSnack("User not authenticated");
      return;
    }

    setState(() => isLoading = true);

    try {
      final newTransaction = TransactionRecord(
        userId: userId,
        title: selectedCategory ?? 'Transaction',
        amount: amount,
        category: selectedCategory ?? '',
        date: DateTime.now(),
        description: noteController.text.trim(),
        type: isIncome ? 'income' : 'expense',
      );

      await firestoreService.addTransaction(newTransaction);

      if (mounted) {
        // Reset form
        amountController.clear();
        noteController.clear();
        setState(() {
          selectedCategory = null;
          isLoading = false;
        });
        _showSnack("Transaksi berhasil ditambahkan");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnack("Error: $e");
      }
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // Tampilkan modal pemilih kategori (kecil, simple)
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text("Select Category", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...categories.map((c) {
                return ListTile(
                  title: Text(c),
                  onTap: () {
                    setState(() {
                      selectedCategory = c;
                    });
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallStatCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
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
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "No transactions yet",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Start by adding your first transaction above",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: transactions.map((t) {
          final amt = t.amount;
          final isInc = t.type == 'income';
          final date = t.date;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isInc ? Colors.green : Colors.red,
                  child: Icon(isInc ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (t.description != null && (t.description ?? '').isNotEmpty)
                        Text(t.description ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(DateFormat('dd MMM yyyy HH:mm').format(date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                Text(
                  (isInc ? '+ ' : '- ') + _formatCurrency(amt),
                  style: TextStyle(
                    color: isInc ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // warna sesuai UI asli (tidak diubah)
    final Color bgRed = const Color(0xFF8B1D2F);
    final Color darkRed = const Color(0xFF570F1A);
    final Color activeGreen = const Color(0xFF66DAA4);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgRed, darkRed],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
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
                      children: const [
                        Text(
                          "My Wallet",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Personal Finance Tracker",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Balance card (UI preserved)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Balance",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(totalBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallStatCard(
                              "Income",
                              _formatCurrency(totalIncome),
                              const Color(0xFFC9F7DE),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallStatCard(
                              "Expenses",
                              _formatCurrency(totalExpense),
                              const Color(0xFFFFE2E2),
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Add Transaction",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isIncome = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isIncome ? activeGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Add Income",
                                style: TextStyle(
                                  color: isIncome ? Colors.white : Colors.black54,
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
                              color: !isIncome ? Colors.redAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Add Expense",
                                style: TextStyle(
                                  color: !isIncome ? Colors.white : Colors.black54,
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

                // Form card (UI preserved)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Amount"),
                      _buildInput(controller: amountController, hint: "Rp 000000"),
                      const SizedBox(height: 16),

                      _buildLabel("Category"),
                      GestureDetector(
                        onTap: _showCategoryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCategory ?? "Select category",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildLabel("Note (Optional)"),
                      _buildInput(controller: noteController, hint: "Add a note...", maxLines: 2),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _addTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isIncome ? activeGreen : Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isIncome ? "Add Income" : "Add Expense",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // History header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Transaction History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("View All", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                // History list (UI preserved)
                _buildHistoryList(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
