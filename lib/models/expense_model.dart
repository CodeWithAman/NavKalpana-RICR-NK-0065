// ExpenseModel
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String categoryName;
  final String note;
  final DateTime date;
  final bool isRecurring;
  final String? merchant; // extracted by AI text parsing

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryName,
    required this.note,
    required this.date,
    this.isRecurring = false,
    this.merchant,
  });

  factory ExpenseModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      amount: (d['amount'] ?? 0).toDouble(),
      categoryName: d['categoryName'] ?? 'Other',
      note: d['note'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
      isRecurring: d['isRecurring'] ?? false,
      merchant: d['merchant'],
    );
  }

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'categoryName': categoryName,
        'note': note,
        'date': Timestamp.fromDate(date),
        'isRecurring': isRecurring,
        if (merchant != null) 'merchant': merchant,
      };

  ExpenseModel copyWith({
    double? amount,
    String? categoryName,
    String? note,
    DateTime? date,
    bool? isRecurring,
  }) =>
      ExpenseModel(
        id: id,
        amount: amount ?? this.amount,
        categoryName: categoryName ?? this.categoryName,
        note: note ?? this.note,
        date: date ?? this.date,
        isRecurring: isRecurring ?? this.isRecurring,
        merchant: merchant,
      );
}
