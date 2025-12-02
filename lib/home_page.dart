import 'package:flutter/material.dart';
import 'add_transaction_page.dart'; // Pastikan file ini ada
import 'recap_page.dart'; // Pastikan file ini ada

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna
    final Color bgRed = const Color(0xFF8B1D2F);
    final Color darkRed = const Color(0xFF570F1A);

    // PERBAIKAN: Menggunakan withValues(alpha: ...) menggantikan withOpacity
    final Color cardBalanceColor = Colors.white.withValues(alpha: 0.15);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgRed, darkRed],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER (Hallo Moetia) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hallo, Moetia",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Welcome back to Fintrack",
                              style: TextStyle(
                                // PERBAIKAN: withValues
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Avatar Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // PERBAIKAN: withValues
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- TOTAL BALANCE CARD (Link ke RecapPage) ---
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke Halaman Rekap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecapPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBalanceColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            // PERBAIKAN: withValues
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance",
                              style: TextStyle(
                                // PERBAIKAN: withValues
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Rp 12.450.000",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    // PERBAIKAN: withValues
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.greenAccent,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "+3.2%",
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "from last month",
                                  style: TextStyle(
                                    // PERBAIKAN: withValues
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- MENU ROW (Income, Expense, Savings) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMenuCard(
                          "Income",
                          "Rp 5.680.000",
                          Icons.arrow_downward,
                        ),
                        _buildMenuCard(
                          "Expenses",
                          "Rp 3.240.000",
                          Icons.arrow_upward,
                        ),
                        _buildMenuCard(
                          "Savings",
                          "Rp 2.440.000",
                          Icons.attach_money,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- SPENDING OVERVIEW (Chart Mockup) ---
                    Container(
                      height: 180,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // PERBAIKAN: withValues
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Spending Overview",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "This Week",
                                style: TextStyle(
                                  // PERBAIKAN: withValues
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Custom Paint untuk menggambar Wave Putih
                          SizedBox(
                            height: 80,
                            width: double.infinity,
                            child: CustomPaint(painter: ChartWavePainter()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- RECENT TRANSACTIONS ---
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
                        Text(
                          "View All",
                          style: TextStyle(
                            // PERBAIKAN: withValues
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List Item 1
                    _buildTransactionItem(
                      icon: Icons.storefront,
                      title: "Grocery Store",
                      date: "Today, 2:30 PM",
                      amount: "-Rp 85.400",
                      isExpense: true,
                    ),
                    const SizedBox(height: 12),

                    // List Item 2
                    _buildTransactionItem(
                      icon: Icons.credit_card,
                      title: "Salary Deposit",
                      date: "Yesterday, 9:00 AM",
                      amount: "+Rp 2.500.000",
                      isExpense: false,
                    ),
                    // Ruang ekstra di bawah agar tidak tertutup FAB/Layar
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // --- FLOATING ADD BUTTON (Link ke AddTransactionPage) ---
              Positioned(
                bottom: 30,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigasi ke Halaman Catat Transaksi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionPage(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Color(0xFF8B1D2F)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper: Menu Card Kecil
  Widget _buildMenuCard(String title, String amount, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF0F0),
            radius: 14,
            child: Icon(icon, color: const Color(0xFF8B1D2F), size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount.replaceAll(" ", "\n"),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Transaction Item
  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8B1D2F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.black87 : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk membuat efek ombak grafik
class ChartWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.7);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.4,
    );

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
