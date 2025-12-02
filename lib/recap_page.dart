import 'package:flutter/material.dart';

class RecapPage extends StatefulWidget {
  const RecapPage({super.key});

  @override
  State<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> {
  int _selectedIndex = 0; // 0 for Income, 1 for Expenses

  @override
  Widget build(BuildContext context) {
    final Color bgRed = const Color(0xFF8B1D2F);
    final Color darkRed = const Color(0xFF570F1A);
    final Color greenColor = const Color(0xFF22C55E);

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
                // --- HEADER ---
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
                    const Text(
                      "Rekap Transaksi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- DATE FILTER ---
                const Text(
                  "Select Month & Year",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "September 2025",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- TABS (Income / Expense) DENGAN WRAPPER ---
                // Ini bagian yang diperbaiki
                Container(
                  padding: const EdgeInsets.all(
                    4,
                  ), // Jarak antara border putih dan tombol
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna dasar pembungkus
                    borderRadius: BorderRadius.circular(30), // Sudut membulat
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton("Income", 0, greenColor)),
                      Expanded(
                        // Gunakan sedikit space jika mau, atau langsung nempel
                        child: _buildTabButton("Expenses", 1, Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- SUMMARY CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Income",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "+Rp.00",
                            style: TextStyle(
                              color: greenColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            "Net Balance",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "+Rp.00",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- TRANSACTION LIST ITEMS ---
                _buildListItem(
                  "Monthly Salary",
                  "Sept 1, 2025",
                  "+Rp 10.000.000",
                  const Color(0xFFE0F7EA),
                  greenColor,
                ),
                const SizedBox(height: 12),
                _buildListItem(
                  "Freelance Project",
                  "Sept 5, 2025",
                  "+Rp 1.500.000",
                  const Color(0xFFE3F2FD),
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Button Tab yang sudah disesuaikan
  Widget _buildTabButton(String title, int index, Color activeColor) {
    bool isSelected = _selectedIndex == index;

    // Warna teks: Kalau expense dipilih (index 1), teksnya hitam (karena background putih/transparent)
    // Tapi kalau di desain mockup, expense juga punya warna background sendiri kalau aktif?
    // Jika melihat mockup:
    // Income Aktif -> Background Hijau, Teks Putih.
    // Expense Aktif (di mockup sebelah kiri) -> Background Putih, Teks Hitam/Abu.
    // Jadi logikanya: Tombol aktif punya background warna, tombol tidak aktif transparan.

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          // Jika dipilih, gunakan warna aktif. Jika tidak, transparan.
          color: isSelected
              ? (index == 0 ? activeColor : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          // Tambahkan shadow atau border jika expense aktif agar terlihat beda dengan background wrapper?
          // Sesuai mockup, expense (sebelah kanan) saat tidak aktif hanya text saja.
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              // Logika warna teks
              color: isSelected
                  ? (index == 0 ? Colors.white : Colors.black87)
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(
    String title,
    String date,
    String amount,
    Color iconBg,
    Color amountColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
