import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/screens/buyer_transaction_screen.dart';
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';
import 'package:movie_app_sertifikasi/models/product_model.dart';
import 'package:movie_app_sertifikasi/models/user_model.dart';

class BuyerHomeScreen extends StatefulWidget {
  final User user;
  const BuyerHomeScreen({super.key, required this.user});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts(); 
  }

  // Fungsi untuk muat ulang data (misal setelah transaksi)
  void _refreshProducts() {
    setState(() {
      _productsFuture = dbHelper.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      
        title: const Text('Pilih Kue Favoritmu 🍰'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts, // Tombol refresh data
            tooltip: 'Refresh',
          ),
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () {
          //     // Navigasi kembali ke LoginScreen
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => const LoginScreen()),
          //     );
          //   },
          //   tooltip: 'Logout',
          // ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                // Tampilkan error lebih baik
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    onPressed: _refreshProducts,
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final List<Product> products = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(12.0), 
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom
                crossAxisSpacing: 12.0, // Jarak horizontal antar card
                mainAxisSpacing: 12.0, // Jarak vertikal antar card
                childAspectRatio: 0.7, // Atur rasio lebar:tinggi card
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final Product product = products[index];
                return Card(
                  // --- Gunakan Card ---
                  clipBehavior:
                      Clip.antiAlias, // Biar gambar tidak keluar border
                  child: InkWell(
                    // Tambah efek klik
                    onTap: () {
                      // Langsung ke transaksi saat card diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyerTransactionScreen(
                            product: product,
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2, 
                          child: Image.network(
                            product.imageUrl, 
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        // --- Detail di Bawah Gambar ---
                        Expanded(
                          flex: 3, // Porsi teks
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.namaKue,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${product.harga}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                ),

                                const Spacer(),
                                // --- Tombol Beli di dalam Card ---
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BuyerTransactionScreen(
                                              product: product,
                                              user: widget.user,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.shopping_cart_checkout,
                                    size: 16,
                                  ),
                                  label: const Text('Beli'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    textStyle: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada kue tersedia.",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
