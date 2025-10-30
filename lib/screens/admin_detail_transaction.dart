import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/models/transaction_model.dart';
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';

class AdminDetailTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const AdminDetailTransactionScreen({
    super.key,
    required this.transaction
  });

  @override
  State<AdminDetailTransactionScreen> createState() =>
      _AdminDetailTransactionScreenState();
}

class _AdminDetailTransactionScreenState
    extends State<AdminDetailTransactionScreen> {
  final dbHelper = DatabaseHelper();
  bool _isUpdating = false; 
  late String _currentStatus; 

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.transaction.status; 
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Sedang Dikirim': return Icons.local_shipping_outlined;
      case 'Selesai': return Icons.check_circle_outline;
      case 'Diterima': return Icons.thumb_up_alt_outlined;
      case 'Menunggu Konfirmasi': default: return Icons.pending_outlined;
    }
  }
  Color _getStatusColor(String status) {
     switch (status) {
      case 'Sedang Dikirim': return Colors.blueAccent;
      case 'Selesai': return Colors.green;
      case 'Diterima': return Colors.teal;
      case 'Menunggu Konfirmasi': default: return Colors.orangeAccent;
    }
  }
  // --- Batas Fungsi Bantuan ---

  // --- Fungsi Untuk Update Status ---
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true); // Mulai loading

    try {
      await dbHelper.updateTransactionStatus(
        widget.transaction.id,
        newStatus
      );
      // Update status di layar
      setState(() {
        _currentStatus = newStatus;
        widget.transaction.status = newStatus; // Update juga data aslinya
      });

      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Status berhasil diubah ke: $newStatus'), backgroundColor: _getStatusColor(newStatus)),
       );
       // Kirim sinyal 'refresh' kembali ke halaman sebelumnya
       Navigator.pop(context, 'refresh');

    } catch (e) {
       print('Error update: $e');
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Gagal update status: $e'), backgroundColor: Colors.redAccent),
       );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false); // Selesai loading
      }
    }
  }
  // --- Batas Fungsi Update ---


  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(_currentStatus);
    IconData statusIcon = _getStatusIcon(_currentStatus);

    return Scaffold(
      appBar: AppBar(title: Text('Detail Transaksi #${widget.transaction.id}')), // Tambah ID
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Lebar penuh
          children: [
            // --- Card Info Pembeli & Kue ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Pesanan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.person_outline, 'Pembeli:', widget.transaction.namaPembeli),
                    _buildDetailRow(Icons.bakery_dining_outlined, 'Kue:', widget.transaction.namaKue),
                    _buildDetailRow(Icons.attach_money, 'Total Harga:', 'Rp ${widget.transaction.totalHarga}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Card Info Lokasi ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi Pengiriman (GPS)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.location_on_outlined, 'Latitude:', widget.transaction.lokasiLat),
                    _buildDetailRow(Icons.location_on_outlined, 'Longitude:', widget.transaction.lokasiLong),
                    // Opsional: Tambah tombol buka Google Maps
                  ],
                ),
              ),
            ),
             const SizedBox(height: 16),

            // --- Card Status Saat Ini ---
            Card(
               color: statusColor.withOpacity(0.1), // Background sesuai warna status
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Row(
                    children: [
                       Icon(statusIcon, color: statusColor, size: 30),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text('Status Saat Ini', style: Theme.of(context).textTheme.labelMedium),
                               Text(
                                 _currentStatus,
                                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                       fontWeight: FontWeight.bold,
                                       color: statusColor
                                 ),
                               ),
                            ],
                         ),
                       ),
                    ],
                 ),
               ),
            ),
            const SizedBox(height: 24),

            // --- Bagian Tombol Aksi ---
            Text(
              'Update Status Transaksi:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tampilkan loading jika sedang update
            if (_isUpdating)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ))
            else
              // Bungkus tombol dalam Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TOMBOL 1: TERIMA (Hanya muncul jika status masih 'Menunggu')
                  if (_currentStatus == 'Menunggu Konfirmasi')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Terima Pesanan'),
                      onPressed: () => _updateStatus('Diterima'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),

                  // TOMBOL 2: KIRIM (Hanya muncul jika status 'Diterima')
                  if (_currentStatus == 'Diterima')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.local_shipping_outlined),
                      label: const Text('Kirim Pesanan'),
                      onPressed: () => _updateStatus('Sedang Dikirim'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    ),

                   // TOMBOL 3: SELESAI (Hanya muncul jika status 'Dikirim')
                  if (_currentStatus == 'Sedang Dikirim')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Selesaikan Transaksi'),
                      onPressed: () => _updateStatus('Selesai'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),

                  // Tampilkan pesan jika sudah Selesai
                  if (_currentStatus == 'Selesai')
                     Padding(
                       padding: const EdgeInsets.symmetric(vertical: 16.0),
                       child: Text(
                         'Transaksi ini sudah selesai.',
                         textAlign: TextAlign.center,
                         style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                       ),
                     ),

                  const SizedBox(height: 8), // Sedikit jarak antar tombol jika ada > 1
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- Widget Bantuan untuk Baris Detail ---
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label ', style: TextStyle(color: Colors.grey[700])),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  // --- Batas Widget Bantuan ---
}