import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:movie_app_sertifikasi/models/user_model.dart';
import 'package:movie_app_sertifikasi/models/product_model.dart';
import 'package:movie_app_sertifikasi/models/transaction_model.dart';

class DatabaseHelper {
  // --- BAGIAN 1: PINTU MASUK (SINGLETON) ---
  static Database? _database; 

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'roti.db');

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT,
      role TEXT)
      ''');

    await db.execute('''
      CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      namaKue TEXT NOT NULL,
      harga INTEGER NOT NULL,
      imageUrl TEXT)
      ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,      
        productId INTEGER NOT NULL,   
        namaPembeli TEXT NOT NULL, 
        totalHarga INTEGER NOT NULL,
        lokasiLat TEXT, 
        lokasiLong TEXT,
        status TEXT NOT NULL 
      )
    ''');
    await _seedDatabase(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE products ADD COLUMN imageUrl TEXT');
  }
}

  //data seeder awal
  Future<void> _seedDatabase(Database db) async {
    await db.rawInsert('''
      INSERT INTO users (username, password, role) 
      VALUES 
        ('admin', 'admin123', 'admin'),
        ('david', 'david123', 'pembeli')
    ''');
    await db.rawInsert('''
    INSERT INTO products (namaKue, harga, imageUrl) 
    VALUES 
      ('Roti Tawar', 15000, 'https://via.placeholder.com/150/FF5733/FFFFFF?text=Roti+Tawar'),
      ('Croissant Coklat', 12000, 'https://via.placeholder.com/150/C70039/FFFFFF?text=Croissant'),
      ('Donat Gula', 8000, 'https://via.placeholder.com/150/900C3F/FFFFFF?text=Donat'),
      ('Bolu Pisang', 25000, 'https://via.placeholder.com/150/581845/FFFFFF?text=Bolu'),
      ('Roti Sobek', 20000, 'https://via.placeholder.com/150/FFC300/FFFFFF?text=Sobek')
  ''');
  }

  //fungsi login
  Future<User?> loginUser(String username, String password) async{
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password =  ?',
      whereArgs: [username, password], 
    );

    if(maps.isNotEmpty){
      return User.fromMap(maps.first);
    }else {
      return null;
    }
  }

  Future<List<Product>> getProducts() async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i){
      return Product.fromMap(maps[i]);
    });
  }

  // --- TAMBAHKAN FUNGSI CRUD PRODUK ---

  // CREATE: Fungsi untuk menambah produk baru
  Future<int> insertProduct(Map<String, dynamic> productData) async {
    final db = await database;
    // 'insert' mengembalikan ID dari baris baru
    return await db.insert('products', productData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // UPDATE: Fungsi untuk mengubah data produk
  Future<int> updateProduct(Map<String, dynamic> productData) async {
    final db = await database;
    final int id = productData['id']; // Ambil ID dari data
    // 'update' mengembalikan jumlah baris yang terpengaruh
    return await db.update(
      'products',
      productData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Fungsi untuk menghapus produk
  Future<int> deleteProduct(int id) async {
    final db = await database;
    // 'delete' mengembalikan jumlah baris yang terhapus
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // --- BATAS FUNGSI CRUD PRODUK ---

  //fungsi insert transaction
  Future<void> insertTransaction(Map<String, dynamic> transactionData) async {
    final Database db = await database;

    await db.insert(
      'transactions', 
      transactionData,
      conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }

  Future<List<TransactionModel>> getAllTransactions () async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        T.id,
        T.totalHarga,
        T.lokasiLat,
        T.lokasiLong,
        T.status,
        P.namaKue,
        U.username AS namaPembeli
      FROM transactions AS T
      JOIN users AS U ON T.userId = U.id
      JOIN products AS P ON T.productId = P.id
      ORDER BY T.id DESC''');
      return List.generate(maps.length, (i){
        return TransactionModel.fromMap(maps[i]);
      });
  }
  
  Future<void> updateTransactionStatus(int id, String newStatus) async {
    final Database db = await database;

    await db.update('transactions', 
    {'status': newStatus},
    where: 'id = ? ',
    whereArgs: [id],
    );
  }

}
