import 'package:flutter/material.dart';
import 'login_page.dart'; // Pastikan import ini ada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fintrack',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Arial', // Ganti dengan font pilihanmu (misal Poppins)
        useMaterial3: true,
      ),
      // Arahkan home pertama kali ke LoginPage
      home: const LoginPage(),
    );
  }
}