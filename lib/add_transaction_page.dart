import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = true;

  // Kontroler form
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Category
  String? selectedCategory;
  final List<String> categories = [
    "Transportation",
    "Food",
    "Lifestyle",
    "Others",
  ];

  // Data lokal untuk history (in-memory). Format: {amount, category, note, isIncome, date}
  final List<Map<String, dynamic>> transactions = [];

  // Totals
  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  final _currencyFormat = NumberFormat('#,##0', 'en_US');

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return "Rp ${_currencyFormat.format(value)}";
  }

  void _addTransaction() {
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

    final entry = {
      'amount': amount,
      'category': selectedCategory!,
      'note': noteController.text.trim(),
      'isIncome': isIncome,
      'date': DateTime.now().toIso8601String(),
    };

    setState(() {
      transactions.insert(0, entry); // newest first
      if (isIncome) {
        totalIncome += amount;
        totalBalance += amount;
      } else {
        totalExpense += amount;
        totalBalance -= amount;
      }

      // reset form
      amountController.clear();
      noteController.clear();
      selectedCategory = null;
    });

    _showSnack("Transaksi berhasil ditambahkan");
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
          final amt = t['amount'] as double;
          final isInc = t['isIncome'] as bool;
          final date = DateTime.parse(t['date'] as String);
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
                      Text(t['category'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if ((t['note'] as String).isNotEmpty)
                        Text(t['note'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                          onPressed: _addTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isIncome ? activeGreen : Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
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
