// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';
import 'admin_home_screen.dart';
import 'buyer_home_screen.dart';
import 'package:movie_app_sertifikasi/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final dbHelper = DatabaseHelper();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Tambah state loading

  Future<void> _login() async {
    setState(() => _isLoading = true); // Mulai loading

    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final User? user = await dbHelper.loginUser(username, password);

    setState(() => _isLoading = false); // Selesai loading

    if (!mounted) return; // Cek jika widget masih ada

    if (user != null) {
      print("Login sukses sebagai: ${user.role}");
      if (user.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else if (user.role == 'pembeli') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuyerHomeScreen(user: user)),
        );
      }
    } else {
      print('Login Gagal: User tidak ditemukan ');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Password Salah'),
          backgroundColor: Colors.redAccent, // Warna lebih soft
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus AppBar jika ingin tampilan login lebih 'full screen'
      // appBar: AppBar(title: const Text('Login Aplikasi Roti')),
      body: SafeArea( // Biar konten tidak nabrak status bar
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Padding lebih besar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Tambah Logo/Ikon ---
                Icon(
                  Icons.bakery_dining_outlined, // Ikon Roti
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Selamat Datang!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login untuk melanjutkan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                // -------------------------
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline), // Ikon di dalam
                    // Hapus border jika ingin lebih minimalis
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Password jadi bintang
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline), // Ikon gembok
                    // suffixIcon: IconButton( // Opsional: Tombol show/hide password
                    //   icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    //   onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    // ),
                  ),
                ),
                const SizedBox(height: 32.0),
                // --- Tombol dengan Loading ---
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login, // Panggil fungsi _login
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                // --------------------------
                const SizedBox(height: 20),
                // Opsional: Link Lupa Password atau Daftar
                // TextButton(
                //   onPressed: () {},
                //   child: Text('Lupa Password?'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}