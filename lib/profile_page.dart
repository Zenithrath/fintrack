import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/services/firestore_service.dart';
import 'package:fintrack/models/user_model.dart';
import 'package:fintrack/models/transaction_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Services
  final authService = AuthService();
  final firestoreService = FirestoreService();

  // State Data
  String displayName = "User";
  String email = "-";
  double totalBalance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fungsi untuk ambil data user & hitung saldo total
  Future<void> _loadProfileData() async {
    final userAuth = authService.currentUser;
    if (userAuth == null) return;

    try {
      // 1. Ambil data profil dari Firestore
      UserModel? userDoc = await firestoreService.getUser(userAuth.uid);

      // LOGIC PINTAR:
      // Kalau data di Firestore kosong (karena error dulu),
      // Ambil nama dari data Login (Auth)
      String finalName = userDoc?.displayName ?? userAuth.displayName ?? "";

      // Kalau masih kosong juga, pakai nama depan dari email
      if (finalName.isEmpty) {
        finalName = userAuth.email!.split('@')[0];
      }

      // 2. Ambil SEMUA transaksi untuk hitung total saldo
      final transactions = await firestoreService.getTransactionsByUser(
        userAuth.uid,
      );

      double income = 0;
      double expense = 0;

      for (var t in transactions) {
        if (t.type == 'income') {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }

      if (mounted) {
        setState(() {
          displayName = finalName;
          email = userDoc?.email ?? userAuth.email ?? "-";
          totalBalance = income - expense;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Format Rupiah
  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna
    const Color bgRed = Color(0xFF8B1D2F);
    const Color bgDarkRed = Color(0xFF570F1A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgRed, bgDarkRed, Color(0xFFA53B4A)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // --- BACKGROUND BUBBLES ---
              Positioned(
                top: 140,
                left: 22,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 200,
                right: 30,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 130,
                left: 38,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                right: 35,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // --- MAIN CONTENT ---
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // HEADER
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.22),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hallo $displayName", // SUDAH DIPERBAIKI
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Welcome to your profile",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // PROFILE CARD
                        Center(
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: bgRed.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: bgRed,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  displayName, // SUDAH DIPERBAIKI
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B1D2F),
                                  ),
                                ),

                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),

                                Text(
                                  "Total Balance",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  _formatCurrency(totalBalance),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B1D2F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // LOGOUT
                        Center(
                          child: Container(
                            width: 230,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFB83246), Color(0xFFA82738)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.22),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () async {
                                await authService.logout();
                                if (mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
