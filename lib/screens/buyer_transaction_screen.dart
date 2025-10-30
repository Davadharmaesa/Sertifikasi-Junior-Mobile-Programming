
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movie_app_sertifikasi/models/product_model.dart';
import 'package:movie_app_sertifikasi/models/user_model.dart';
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';

class BuyerTransactionScreen extends StatefulWidget {
  final Product product;
  final User user;

  const BuyerTransactionScreen({
    super.key,
    required this.product,
    required this.user,
  });

  @override
  State<BuyerTransactionScreen> createState() => _BuyerTransactionScreenState();
}

class _BuyerTransactionScreenState extends State<BuyerTransactionScreen> {
  final dbHelper = DatabaseHelper();
  String _locationMessage = "Lokasi pengiriman belum diambil.";
  String _latLong = "";
  bool _isLoadingGps = false;
  bool _isSaving = false; 

  // --- Fungsi GPS ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingGps = true);
    // ... (kode _getCurrentLocation ) ...
     bool serviceEnabled;
     LocationPermission permission;
     serviceEnabled = await Geolocator.isLocationServiceEnabled();

     if (!serviceEnabled) {
       setState(() {
         _locationMessage = "Error: Layanan GPS di HP Anda mati.";
         _isLoadingGps = false;
       });
       return;
     }

     permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied) {
         setState(() {
           _locationMessage = "Error: Anda menolak izin lokasi.";
           _isLoadingGps = false;
         });
         return;
       }
     }

     if (permission == LocationPermission.deniedForever) {
       setState(() {
         _locationMessage = "Error: Izin lokasi ditolak permanen.";
         _isLoadingGps = false;
       });
       return;
     }

     try {
       Position position = await Geolocator.getCurrentPosition(
         desiredAccuracy: LocationAccuracy.high,
       );
       setState(() {
         _locationMessage = "✅ Lokasi berhasil didapatkan!"; // Tambah ikon
         _latLong = "Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}"; // Format 6 angka desimal
         _isLoadingGps = false;
       });
     } catch (e) {
       setState(() {
         _locationMessage = "Error: Gagal mendapat lokasi. ${e.toString()}";
         _isLoadingGps = false;
       });
     }
  }
  // --- Batas Fungsi GPS ---

  // --- Fungsi Simpan Transaksi ---
  Future<void> _saveTransaction() async {
     if (_latLong.isEmpty) return; // Jangan simpan jika lokasi kosong

     setState(() => _isSaving = true); // Mulai loading simpan

     final lat = _latLong.split(', ')[0].split(': ')[1];
     final long = _latLong.split(', ')[1].split(': ')[1];

     Map<String, dynamic> transactionData = {
       'userId': widget.user.id,
       'productId': widget.product.id,
       'namaPembeli': widget.user.username,
       'totalHarga': widget.product.harga,
       'lokasiLat': lat,
       'lokasiLong': long,
       'status': 'Menunggu Konfirmasi'
     };

     try {
       await dbHelper.insertTransaction(transactionData);
       if (!mounted) return; // Cek jika widget masih ada
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('👍 Transaksi berhasil disimpan!'),
           backgroundColor: Colors.green,
         ),
       );
       Navigator.pop(context);
     } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Gagal menyimpan transaksi: $e'),
           backgroundColor: Colors.redAccent,
         ),
       );
     } finally {
        if (mounted) {
           setState(() => _isSaving = false); // Selesai loading simpan
        }
     }
  }
 // --- Batas Fungsi Simpan ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Transaksi 🛒'),
      ),
      body: SingleChildScrollView( // Bungkus Column dengan SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Bikin lebar penuh
          children: [
            // --- Card Detail Kue ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Anda:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        // Gambar Kecil
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.bakery_dining, size: 60),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Nama dan Harga
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.namaKue,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${widget.product.harga}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Bagian Lokasi ---
            Text(
              'Lokasi Pengiriman:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container( // Beri background & border
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.shade50,
              ),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                    Text(
                      _locationMessage,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: _locationMessage.startsWith("Error") ? Colors.red : Colors.black87,
                      ),
                    ),
                    if (_latLong.isNotEmpty) ...[ // Tampilkan jika ada
                      const SizedBox(height: 4),
                      Text(
                        _latLong,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ]
                 ],
              )
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: _isLoadingGps
                  ? Container( // Ganti CicularProgressIndicator kecil
                      width: 18, height: 18,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isLoadingGps ? 'Mencari...' : 'Ambil Lokasi Saat Ini'),
              onPressed: _isLoadingGps ? null : _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Warna beda untuk aksi ini
              ),
            ),
            const SizedBox(height: 32),

            // --- Tombol Konfirmasi ---
            _isSaving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Konfirmasi & Pesan Sekarang', style: TextStyle(fontSize: 16)),
                  onPressed: _latLong.isEmpty ? null : _saveTransaction, // Panggil fungsi simpan
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green, // Warna konfirmasi
                     disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}