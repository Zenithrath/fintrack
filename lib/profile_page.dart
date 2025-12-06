import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B1D2F),
              Color(0xFF9A2E3E),
              Color(0xFFA53B4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [

              // -----------------------------------------------------------
              //  FLOATING BACKGROUND BUBBLES — 100% PRESISI DARI UI
              // -----------------------------------------------------------
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

              // -----------------------------------------------------------
              // MAIN CONTENT
              // -----------------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 5),

                  // BACK BUTTON + TEXT
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

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hallo Moetia",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
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

                  // PROFILE CARD — MATCH THE UI EXACTLY
                  Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 20),
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
                          const Text(
                            "Moetia Safitri Agustina",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B1D2F),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "total balance",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Rp 57.000.000",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B1D2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 90),

                  // LOGOUT BUTTON — 100% MATCH UI
                  Center(
                    child: Container(
                      width: 230,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFB83246),
                            Color(0xFFA82738),
                          ],
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
