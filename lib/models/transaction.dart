import 'medicine.dart';  // Import your Medicine model file

class Transaction {
  final int transactionId;
  final String address;
  final String status;
  final int medicineId;
  final int userId;
  final Medicine medicine; // Add this line
  final int quantity; // Add this line

  Transaction({
    required this.transactionId,
    required this.address,
    required this.status,
    required this.medicineId,
    required this.userId,
    required this.medicine,
    required this.quantity,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: int.parse(json['transaction_id'] ?? '0'),
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      medicineId: int.parse(json['medicine_id'] ?? '0'),
      userId: int.parse(json['user_id'] ?? '0'),
      medicine: Medicine.fromJson(json), // Assume Medicine has a fromJson method
      quantity: int.parse(json['quantity'] ?? '0'),
    );
  }
}
