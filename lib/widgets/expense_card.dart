// ExpenseCard widget
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final String symbol;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.symbol = '₹',
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surface3,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long, color: AppTheme.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(expense.categoryName,
              style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            expense.note.isNotEmpty ? expense.note : DateFormat('dd MMM').format(expense.date),
            style: const TextStyle(color: AppTheme.textSec, fontSize: 12),
          ),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('-$symbol${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
          if (expense.isRecurring)
            const Text('🔁 Recurring',
                style: TextStyle(color: AppTheme.warning, fontSize: 10)),
        ]),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline, color: AppTheme.textDim, size: 18),
          ),
        ],
      ]),
    );
  }
}
