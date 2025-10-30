class TransactionModel {
  final int id;
  final String namaPembeli;
  final String namaKue;
  final int totalHarga;
  final String lokasiLat;
  final String lokasiLong;
  String status;

  TransactionModel({
    required this.id,
    required this.namaPembeli,
    required this.namaKue,
    required this.totalHarga,
    required this.lokasiLat,
    required this.lokasiLong,
    required this.status, 
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map){
    return TransactionModel(
      id: map['id'], 
      namaPembeli: map['namaPembeli'],
      namaKue: map['namaKue'], 
      totalHarga: map['totalHarga'], 
      lokasiLat: map['lokasiLat'], 
      lokasiLong: map['lokasiLong'], 
      status: map['status'],
      );
  }
}