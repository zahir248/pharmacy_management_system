import 'dart:typed_data';
import 'dart:convert';

class Medicine {
  final int medicineId;
  final String name;
  final Uint8List imageData;
  final double price;
  final int quantity;

  Medicine({
    required this.medicineId,
    required this.name,
    required this.imageData,
    required this.price,
    required this.quantity,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    Uint8List decodedImageData = base64.decode(json['image'] ?? '');
    return Medicine(
      medicineId: int.parse(json['medicine_id'] ?? '0'),
      name: json['name'] as String? ?? '',
      imageData: decodedImageData,
      price: double.parse(json['price'] ?? '0.0'),
      quantity: int.parse(json['quantity'] ?? '0'),
    );
  }
}
