class Product{
  final int id;
  final String namaKue;
  final int harga;
  final String imageUrl;

  Product({
    required this.id,
    required this.namaKue,
    required this.harga,
    required this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic>map){
    return Product(
      id: map['id'], 
      namaKue: map['namaKue'], 
      harga: map['harga'],
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',);
  }
}