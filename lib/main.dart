import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart'; // pastikan nama file kamu benar (sign_up_page.dart)

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
        fontFamily: 'Arial',
        useMaterial3: true,
      ),

      // Halaman pertama kali dibuka
      home: const LoginPage(),

      // Routing
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
