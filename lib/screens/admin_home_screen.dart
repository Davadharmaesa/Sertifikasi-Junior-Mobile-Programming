import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/screens/add_edit_product_screen.dart'; 
import 'package:movie_app_sertifikasi/models/product_model.dart';
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';
import 'package:movie_app_sertifikasi/screens/admin_transaction_list.dart';
import 'package:movie_app_sertifikasi/screens/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts(); 
  }


  void _refreshProducts() {
    setState(() {
      _productsFuture = dbHelper.getProducts(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(


        title: const Text('🍰 Kelola Produk Kue'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminTransactionListScreen(),
                ), 
              );
            },
            tooltip: 'Lihat Transaksi',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      // --- Ganti body jadi FutureBuilder untuk Products ---
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              // Tampilkan error produk
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data produk: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: _refreshProducts,
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final List<Product> products = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    // ListTile lebih cocok untuk admin
                    leading: CircleAvatar(
                      // Gambar kecil bulat
                      backgroundImage: NetworkImage(product.imageUrl),
                      onBackgroundImageError:
                          (exception, stackTrace) {}, // Handle error
                      child: product.imageUrl.isEmpty
                          ? const Icon(
                              Icons.cake_outlined,
                            ) // Placeholder jika URL kosong
                          : null,
                    ),
                    title: Text(
                      product.namaKue,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Rp ${product.harga}'),
                    trailing: const Icon(Icons.edit_note), // Ikon edit
                    onTap: () async {
                      // Buka form edit saat diklik
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditProductScreen(
                            product: product, // Kirim produk untuk mode edit
                          ),
                        ),
                      );
                      // Refresh jika ada perubahan
                      if (result == 'refresh') {
                        _refreshProducts();
                      }
                    },
                  ),
                );
              },
            );
          } else {
            // Tampilan jika tidak ada produk
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_business_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada produk ditambahkan.",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tekan tombol '+' untuk menambah.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditProductScreen(),
            ),
          );
          if (result == 'refresh') {
            _refreshProducts();
          }
        },
        tooltip: 'Tambah Produk Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}
