// lib/screens/add_edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk input angka
// Ganti nama proyekmu
import 'package:movie_app_sertifikasi/helpers/database_helper.dart';
import 'package:movie_app_sertifikasi/models/product_model.dart';

class AddEditProductScreen extends StatefulWidget {
  // Terima produk yang mau diedit (opsional)
  // Kalau null, berarti mode 'Tambah'
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form

  // Controller untuk input
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _imageUrlController;

  bool _isEditMode = false; // Penanda mode edit
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.product != null; // Cek apakah ini mode edit

    // Isi controller dengan data lama (jika edit) atau kosong (jika tambah)
    _namaController = TextEditingController(text: widget.product?.namaKue ?? '');
    _hargaController = TextEditingController(text: widget.product?.harga.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
  }

  @override
  void dispose() {
    // Jangan lupa dispose controller
    _namaController.dispose();
    _hargaController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // --- Fungsi Simpan (Bisa Insert atau Update) ---
  Future<void> _saveProduct() async {
    // Validasi form dulu
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Siapkan data Map
      Map<String, dynamic> productData = {
        'namaKue': _namaController.text,
        // Ubah teks harga jadi angka (integer)
        'harga': int.tryParse(_hargaController.text) ?? 0,
        'imageUrl': _imageUrlController.text,
      };

      try {
        if (_isEditMode) {
          // --- MODE EDIT: Panggil UPDATE ---
          productData['id'] = widget.product!.id; // Sertakan ID
          await dbHelper.updateProduct(productData);
        } else {
          // --- MODE TAMBAH: Panggil INSERT ---
          await dbHelper.insertProduct(productData);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Produk berhasil ${ _isEditMode ? "diupdate" : "disimpan"}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, 'refresh'); // Kembali & kirim sinyal refresh

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan produk: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
         if (mounted) {
           setState(() => _isLoading = false);
         }
      }
    }
  }
  // --- Batas Fungsi Simpan ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul berubah sesuai mode
        title: Text(_isEditMode ? 'Edit Produk Kue' : 'Tambah Produk Kue Baru'),
        actions: [
          // Tambah tombol Hapus jika mode Edit
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus Produk',
              onPressed: _deleteProduct, // Panggil fungsi hapus
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Gunakan Form widget untuk validasi
        child: Form(
          key: _formKey, // Pasang kuncinya
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kue',
                  prefixIcon: Icon(Icons.bakery_dining_outlined),
                ),
                // Validasi: tidak boleh kosong
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kue tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number, // Keyboard angka
                // Hanya izinkan input angka
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                // Validasi: harus angka & tidak boleh kosong
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  prefixIcon: Icon(Icons.image_outlined),
                  hintText: 'https://via.placeholder.com/150...',
                ),
                keyboardType: TextInputType.url,
                // Validasi: boleh kosong, tapi jika diisi harus URL valid (simple check)
                validator: (value) {
                   if (value != null && value.isNotEmpty && !value.startsWith('http')) {
                     return 'URL tidak valid';
                   }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(_isEditMode ? Icons.save_alt : Icons.add_circle_outline),
                      label: Text(_isEditMode ? 'Update Produk' : 'Simpan Produk Baru'),
                      onPressed: _saveProduct, // Panggil fungsi simpan
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Fungsi Hapus ---
  Future<void> _deleteProduct() async {
     // Tampilkan dialog konfirmasi
     final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Anda yakin ingin menghapus "${widget.product?.namaKue}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Batal
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Yakin
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        ),
     );

     // Jika user menekan 'Hapus'
     if (confirm == true && widget.product != null) {
       setState(() => _isLoading = true);
       try {
         await dbHelper.deleteProduct(widget.product!.id);
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil dihapus!'),
              backgroundColor: Colors.orange, // Warna info
            ),
         );
         Navigator.pop(context, 'refresh'); // Kembali & kirim sinyal refresh
       } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus produk: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
       } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
       }
     }
  }
  // --- Batas Fungsi Hapus ---
}