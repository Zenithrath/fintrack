import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_page.dart';
import 'signup_page.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        useMaterial3: true,
      ),

      home: const LoginPage(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  } 
}