// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/models/transaction_model.dart';
import 'add_transaction_page.dart';
import 'profile_page.dart';
import 'recap_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final firestoreService = FirestoreService();

  // Data Streams
  Stream<List<TransactionRecord>>? transactionStream;

  String userName = "User";

  // Format mata uang
  final _currencyFormatCompact = NumberFormat.compact(locale: 'id_ID');
  final _currencyFormatFull = NumberFormat('#,##0', 'id_ID');

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final user = authService.currentUser;
    if (user != null) {
      // Real-time stream transaksi untuk user
      transactionStream = firestoreService.getTransactionsByUserStream(
        user.uid,
      );

      // Nama user
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        setState(() => userName = user.displayName!);
      } else {
        _loadUserNameFromFirestore(user.uid);
      }
    }
  }

  void _loadUserNameFromFirestore(String userId) async {
    try {
      final userDoc = await firestoreService.getUser(userId);
      if (mounted && userDoc != null && userDoc.displayName.isNotEmpty) {
        setState(() => userName = userDoc.displayName);
      }
    } catch (_) {}
  }

  // --- PERSENTASE DINAMIS: income vs expense (bulan ini) ---
  /// Mengembalikan widget persentase berdasarkan income & expense (real, tidak dibatasi 100%)
  Widget _buildPercentageIndicator(double income, double expense) {
    double pct = 0;
    bool isIncomeDominant = true;

    // Jika income dan expense sama 0 -> 0%
    if (income == 0 && expense == 0) {
      pct = 0;
      isIncomeDominant = true;
    } else if (income >= expense) {
      // Income dominating (inkl. case expense == 0)
      pct = (income / (expense == 0 ? 1 : expense)) * 100;
      isIncomeDominant = true;
    } else {
      // Expense dominating
      pct = (expense / (income == 0 ? 1 : income)) * 100;
      isIncomeDominant = false;
    }

    // Tampilkan tanpa memotong (real apa adanya), tapi format wajar
    final pctText = pct.isFinite ? pct.toStringAsFixed(1) : '0.0';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isIncomeDominant
                ? Colors.green.withOpacity(0.18)
                : Colors.red.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isIncomeDominant ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncomeDominant
                    ? Colors.lightGreenAccent
                    : Colors.redAccent,
                size: 12,
              ),
              const SizedBox(width: 6),
              Text(
                "${pctText}%",
                style: TextStyle(
                  color: isIncomeDominant
                      ? Colors.lightGreenAccent
                      : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isIncomeDominant ? "Income > Expenses" : "Expenses > Income",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  // --- BAR GROUPS (SENIN - MINGGU) ---
  List<BarChartGroupData> _generateBarGroups(
    List<TransactionRecord> transactions,
  ) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    List<double> weeklyIncome = List.filled(7, 0.0);
    List<double> weeklyExpense = List.filled(7, 0.0);

    for (var t in transactions) {
      DateTime tDate = t.date;
      if (tDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          tDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        int dayIndex = tDate.weekday - 1;
        if (t.type == 'income') {
          weeklyIncome[dayIndex] += t.amount;
        } else {
          weeklyExpense[dayIndex] += t.amount;
        }
      }
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyIncome[index],
            color: const Color(0xFF4ADE80),
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: weeklyExpense[index],
            color: const Color(0xFFEF4444),
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  String _getDayName(int index) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    if (index >= 0 && index < days.length) return days[index];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (transactionStream == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF570F1A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    const Color bgDark = Color(0xFF570F1A);
    const Color bgLight = Color(0xFF8B1D2F);
    const Color accentRed = Color(0xFFB94A4A);

    return Scaffold(
      backgroundColor: bgDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionPage()),
        ),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: bgLight, size: 28),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgLight, bgDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            SafeArea(
              child: StreamBuilder<List<TransactionRecord>>(
                stream: transactionStream,
                builder: (context, snapshot) {
                  // default values
                  double income = 0;
                  double expense = 0;
                  double currentBalance = 0;
                  List<TransactionRecord> transactions = [];

                  if (snapshot.hasData) {
                    transactions = snapshot.data!;

                    // Hitung hanya untuk bulan berjalan (realtime)
                    final now = DateTime.now();
                    for (var t in transactions) {
                      if (t.date.year == now.year &&
                          t.date.month == now.month) {
                        if (t.type == 'income')
                          income += t.amount;
                        else
                          expense += t.amount;
                      }
                    }

                    currentBalance = income - expense;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hallo, $userName",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Welcome back to Fintrack",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // TOTAL BALANCE CARD (Reaksi realtime dari stream)
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total Balance (This Month)",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Rp ${_currencyFormatFull.format(currentBalance)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // PERSENTASE: Income vs Expense (bulan ini)
                                  _buildPercentageIndicator(income, expense),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildSmallCard(
                                  Icons.arrow_downward,
                                  "Income",
                                  income,
                                ),
                                const SizedBox(width: 12),
                                _buildSmallCard(
                                  Icons.arrow_upward,
                                  "Expenses",
                                  expense,
                                ),
                                const SizedBox(width: 12),
                                _buildSmallCard(
                                  Icons.account_balance_wallet,
                                  "Total",
                                  currentBalance,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // BAR CHART (Weekly) - masih pakai data stream keseluruhan, filter di generator
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecapPage(),
                            ),
                          ),
                          child: Container(
                            height: 280,
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      "Weekly Summary",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4ADE80),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Income",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Expense",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                Expanded(
                                  child:
                                      (snapshot.hasData &&
                                          snapshot.data!.isNotEmpty)
                                      ? BarChart(
                                          BarChartData(
                                            alignment:
                                                BarChartAlignment.spaceAround,
                                            maxY: null,
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              horizontalInterval: 1000000,
                                              getDrawingHorizontalLine:
                                                  (value) => FlLine(
                                                    color: Colors.white
                                                        .withOpacity(0.05),
                                                    strokeWidth: 1,
                                                  ),
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 8.0,
                                                          ),
                                                      child: Text(
                                                        _getDayName(
                                                          value.toInt(),
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 30,
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            barGroups: _generateBarGroups(
                                              snapshot.data!,
                                            ),
                                            barTouchData: BarTouchData(
                                              enabled: true,
                                              touchTooltipData: BarTouchTooltipData(
                                                tooltipBgColor: Colors.black
                                                    .withOpacity(0.8),
                                                tooltipPadding:
                                                    const EdgeInsets.all(8),
                                                tooltipMargin: 8,
                                                getTooltipItem:
                                                    (
                                                      group,
                                                      groupIndex,
                                                      rod,
                                                      rodIndex,
                                                    ) {
                                                      String label =
                                                          rodIndex == 0
                                                          ? "Income"
                                                          : "Expense";
                                                      return BarTooltipItem(
                                                        "$label\n",
                                                        const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                _currencyFormatCompact
                                                                    .format(
                                                                      rod.toY,
                                                                    ),
                                                            style: TextStyle(
                                                              color:
                                                                  rodIndex == 0
                                                                  ? const Color(
                                                                      0xFF4ADE80,
                                                                    )
                                                                  : const Color(
                                                                      0xFFEF4444,
                                                                    ),
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: Text(
                                            "No data yet",
                                            style: TextStyle(
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // RECENT TRANSACTIONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Recent Transactions",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecapPage(),
                                ),
                              ),
                              child: const Text(
                                "View All",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        else
                          _buildRecentList(transactions, accentRed),

                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList(
    List<TransactionRecord> transactions,
    Color accentRed,
  ) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Belum ada transaksi",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final listCount = transactions.length >= 5 ? 5 : transactions.length;
    return ListView.separated(
      itemCount: listCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isIncome = t.type == 'income';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE8EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.shopping_bag_outlined,
                  color: accentRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF570F1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(t.date),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                (isIncome ? "+ " : "- ") +
                    "Rp ${_currencyFormatFull.format(t.amount)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? Colors.green : const Color(0xFF8B1D2F),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallCard(IconData icon, String label, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFBE8EA)),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFFB94A4A)),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB94A4A),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Rp\n${_currencyFormatCompact.format(amount)}",
              style: const TextStyle(
                color: Color(0xFF570F1A),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
