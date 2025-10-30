
import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/screens/admin_detail_transaction.dart';
import 'package:movie_app_sertifikasi/models/transaction_model.dart';
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';

class AdminTransactionListScreen extends StatefulWidget {
  const AdminTransactionListScreen({super.key});

  @override
  State<AdminTransactionListScreen> createState() => _AdminTransactionListScreenState();
}

class _AdminTransactionListScreenState extends State<AdminTransactionListScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshTransactions(); 
  }


  void _refreshTransactions() {
    setState(() {
      _transactionsFuture = dbHelper.getAllTransactions();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧾 Daftar Transaksi'), // Judul khusus transaksi
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center( // Tampilkan error transaksi
               child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text('Gagal memuat data transaksi: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: _refreshTransactions,
                    )
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final List<TransactionModel> transactions = snapshot.data!;
            // --- Tampilkan daftar transaksi pakai Card ---
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: transactions.map((transaction) {
                Color statusColor = _getStatusColor(transaction.status);
                IconData statusIcon = _getStatusIcon(transaction.status);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      // Buka halaman detail transaksi
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pastikan nama class ini benar (sesuai file detailmu)
                          builder: (context) => AdminDetailTransactionScreen( 
                            transaction: transaction,
                          ),
                        ),
                      );
                      // Refresh jika ada perubahan status
                      if (result == 'refresh') {
                        _refreshTransactions();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pembeli: ${transaction.namaPembeli}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text('Kue: ${transaction.namaKue}', maxLines: 1, overflow: TextOverflow.ellipsis,),
                                const SizedBox(height: 4.0),
                                Text('Total: Rp ${transaction.totalHarga}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                           const SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  transaction.status,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                               const SizedBox(height: 8.0),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            // Tampilan jika tidak ada transaksi
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada transaksi masuk.", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}