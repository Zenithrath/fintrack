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
              //  BACKGROUND BUBBLES (SAMA SEPERTI DESAIN)
              // -----------------------------------------------------------
              Positioned(
                top: 120,
                left: 20,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 220,
                right: 28,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 140,
                left: 40,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                right: 40,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // -----------------------------------------------------------
              //  CONTENT
              // -----------------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // BACK BUTTON + TITLE
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white),
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
                          Text(
                            "Welcome to your profile",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 50),

                  // PROFILE CARD
                  Center(
                    child: Container(
                      width: 290,
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Moetia Safitri Agustina",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B1D2F),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "total balance",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
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

                  const SizedBox(height: 80),

                  // LOGOUT BUTTON
                  Center(
                    child: Container(
                      width: 220,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFB83246),
                            Color(0xFFA82738),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

