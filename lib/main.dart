// lib/main.dart
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
      title: 'Aplikasi Roti Enak', // Judul lebih menarik
      
      // --- TAMBAHKAN TEMA ---
      theme: ThemeData(
        // Skema Warna (Pilih warna primer, misal coklat roti)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown, // Warna dasar
          brightness: Brightness.light,
          primary: Colors.brown[600],
          secondary: Colors.orange[700],
        ),
        
        // Tema AppBar (Seragam di semua halaman)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[600],
          foregroundColor: Colors.white, // Warna teks di AppBar
          elevation: 4.0, // Kasih bayangan dikit
        ),
        
        // Tema Tombol (Biar konsisten)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700], // Warna tombol utama
            foregroundColor: Colors.white, // Warna teks tombol
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Tombol agak rounded
            ),
          ),
        ),

        // Tema Input Field (Biar rapi)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown[600]!, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.brown[800]),
        ),

        cardTheme: CardThemeData(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),

        // Font (Opsional, pakai font default saja sudah bagus)
        fontFamily: 'Roboto', // Atau font lain jika sudah di-setup
        
        useMaterial3: true, // Aktifkan Material 3
      ),
      // --- BATAS TEMA ---
      
      home: const LoginScreen(),
    );
  }
}