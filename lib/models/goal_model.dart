// =====================================================
// GoalModel – savings / financial goal
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalType { emergencyFund, vacation, gadget, education, debtRepayment, custom }

class GoalModel {
  final String id;
  final String title;
  final GoalType type;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final int priority; // 1 = highest
  final double monthlyAllocation;

  const GoalModel({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.priority,
    this.monthlyAllocation = 0,
  });

  /// Progress percentage 0–1
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  /// Months remaining to deadline
  int get monthsRemaining {
    final now = DateTime.now();
    return ((deadline.year - now.year) * 12 + (deadline.month - now.month))
        .clamp(0, 9999);
  }

  /// Required monthly savings to hit goal
  double get requiredMonthlySaving {
    final remaining = targetAmount - savedAmount;
    final months = monthsRemaining;
    return months > 0 ? remaining / months : remaining;
  }

  factory GoalModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: d['title'] ?? 'Goal',
      type: GoalType.values.firstWhere(
        (e) => e.name == (d['type'] ?? 'custom'),
        orElse: () => GoalType.custom,
      ),
      targetAmount: (d['targetAmount'] ?? 0).toDouble(),
      savedAmount: (d['savedAmount'] ?? 0).toDouble(),
      deadline: (d['deadline'] as Timestamp).toDate(),
      priority: d['priority'] ?? 1,
      monthlyAllocation: (d['monthlyAllocation'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type.name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': Timestamp.fromDate(deadline),
        'priority': priority,
        'monthlyAllocation': monthlyAllocation,
      };
}
