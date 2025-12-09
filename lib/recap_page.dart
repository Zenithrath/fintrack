import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/models/transaction_model.dart';

class RecapPage extends StatefulWidget {
  const RecapPage({super.key});

  @override
  State<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> {
  final authService = AuthService();
  final firestoreService = FirestoreService();

  late DateTime selectedMonth;
  int _selectedTab = 0; // 0 = Income, 1 = Expense

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  Future<List<TransactionRecord>> _getMonthTransactions() async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return [];

    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    return firestoreService.getTransactionsByDateRange(userId, start, end);
  }

  @override
  Widget build(BuildContext context) {
    final Color bgRed = const Color(0xFF8B1D2F);
    final Color darkRed = const Color(0xFF570F1A);
    final currencyFormat = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgRed, darkRed],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER ------------------------------------------------------
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rekap Transaksi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Lihat ringkasan bulanan",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // MONTH DROPDOWN -----------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 162,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DateTime>(
                      value: selectedMonth,
                      dropdownColor: Colors.black87,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: List.generate(24, (i) {
                        final date = DateTime(
                          DateTime.now().year,
                          DateTime.now().month - i,
                          1,
                        );
                        return DropdownMenuItem(
                          value: date,
                          child: Text(
                            DateFormat('MMMM yyyy', 'id_ID').format(date),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedMonth = value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // TOGGLE ------------------------------------------------------
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
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0
                                  ? Colors.green
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Income",
                                style: TextStyle(
                                  color: _selectedTab == 0
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1
                                  ? Colors.redAccent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Expenses",
                                style: TextStyle(
                                  color: _selectedTab == 1
                                      ? Colors.white
                                      : Colors.black54,
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

                const SizedBox(height: 24),

                // FUTURE BUILDER ----------------------------------------------
                FutureBuilder<List<TransactionRecord>>(
                  future: _getMonthTransactions(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final list = snap.data!;
                    final incomes = list
                        .where((t) => t.type == "income")
                        .toList();
                    final expenses = list
                        .where((t) => t.type == "expense")
                        .toList();

                    final totalIncome = incomes.fold(
                      0.0,
                      (sum, t) => sum + t.amount,
                    );
                    final totalExpense = expenses.fold(
                      0.0,
                      (sum, t) => sum + t.amount,
                    );
                    final netBalance = totalIncome - totalExpense;

                    final filtered = _selectedTab == 0 ? incomes : expenses;

                    // SUMMARY CARD FIXED LAYOUT -------------------------
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ALWAYS LEFT → INCOME
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Income",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Rp ${currencyFormat.format(totalIncome)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              // ALWAYS CENTER → NET BALANCE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Net Balance",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Rp ${currencyFormat.format(netBalance)}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: netBalance >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              // ALWAYS RIGHT → EXPENSE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Expenses",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Rp ${currencyFormat.format(totalExpense)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // LIST -------------------------------------------
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: filtered.map((t) {
                              final isIncome = t.type == "income";
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: isIncome
                                          ? Colors.green
                                          : Colors.red,
                                      child: Icon(
                                        isIncome
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color: Colors.white,
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
                                            DateFormat(
                                              "dd MMM yyyy",
                                              "id_ID",
                                            ).format(t.date),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "Rp ${currencyFormat.format(t.amount)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
