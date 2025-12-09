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
  int _selectedTab = 0; // 0 for Income, 1 for Expenses

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
  }

  Future<List<TransactionRecord>> _getMonthTransactions() async {
    final userId = authService.currentUser?.uid;
    if (userId == null) return [];

    final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    return firestoreService.getTransactionsByDateRange(userId, startDate, endDate);
  }

  void _changeMonth(int direction) {
    setState(() {
      if (direction > 0) {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
      } else {
        selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color bgRed = const Color(0xFF8B1D2F);
    final Color darkRed = const Color(0xFF570F1A);
    final currencyFormat = NumberFormat('#,##0', 'en_US');

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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
                          "Financial Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "View your monthly summary",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // MONTH SELECTOR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _changeMonth(-1),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      ),
                      Column(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedMonth,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => selectedMonth = picked);
                              }
                            },
                            child: const Text(
                              "Select Date",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _changeMonth(1),
                        child: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // INCOME vs EXPENSE TOGGLE
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
                              color: _selectedTab == 0 ? const Color(0xFF22C55E) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Income",
                                style: TextStyle(
                                  color: _selectedTab == 0 ? Colors.white : Colors.black54,
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
                              color: _selectedTab == 1 ? Colors.redAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Expenses",
                                style: TextStyle(
                                  color: _selectedTab == 1 ? Colors.white : Colors.black54,
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

                // TRANSACTIONS LIST
                FutureBuilder<List<TransactionRecord>>(
                  future: _getMonthTransactions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text("Error loading transactions"),
                        ),
                      );
                    }

                    // Filter based on tab
                    final transactions = snapshot.data ?? [];
                    final filtered = transactions.where((t) {
                      if (_selectedTab == 0) {
                        return t.type == 'income';
                      } else {
                        return t.type == 'expense';
                      }
                    }).toList();

                    if (filtered.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No ${_selectedTab == 0 ? 'income' : 'expenses'} found",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "for ${DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth)}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Calculate total
                    double total = 0;
                    for (var t in filtered) {
                      total += t.amount;
                    }

                    return Column(
                      children: [
                        // TOTAL CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? const Color(0xFFC9F7DE)
                                : const Color(0xFFFFE2E2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  color:
                                      _selectedTab == 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Rp ${currencyFormat.format(total)}",
                                style: TextStyle(
                                  color:
                                      _selectedTab == 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TRANSACTIONS
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: filtered.map((t) {
                              final isIncome = t.type == 'income';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          isIncome ? Colors.green : Colors.red,
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
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (t.description != null &&
                                              (t.description ?? '').isNotEmpty)
                                            Text(
                                              t.description!,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          Text(
                                            DateFormat('dd MMM yyyy HH:mm')
                                                .format(t.date),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "Rp ${currencyFormat.format(t.amount)}",
                                      style: TextStyle(
                                        color:
                                            isIncome ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
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

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
