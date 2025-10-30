import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Roti', 
      home: const LoginScreen(), 
      
    );
  }
}