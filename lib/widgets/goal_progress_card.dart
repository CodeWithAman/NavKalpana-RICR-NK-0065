// GoalProgressCard widget
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/goal_model.dart';
import 'package:intl/intl.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onAddAmount;
  final VoidCallback onDelete;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.onAddAmount,
    required this.onDelete,
  });

  static const _typeIcons = {
    GoalType.emergencyFund: Icons.health_and_safety,
    GoalType.vacation:      Icons.beach_access,
    GoalType.gadget:        Icons.devices,
    GoalType.education:     Icons.school,
    GoalType.debtRepayment: Icons.credit_card,
    GoalType.custom:        Icons.star,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcons[goal.type] ?? Icons.savings;
    final progress = goal.progress;
    final isComplete = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? AppTheme.accentAlt.withOpacity(0.4) : AppTheme.border,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(goal.title,
                style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700)),
            Text('Deadline: ${DateFormat('dd MMM yyyy').format(goal.deadline)}',
                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          ])),
          if (isComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentAlt.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('✓ Done', style: TextStyle(color: AppTheme.accentAlt, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.textDim, size: 18),
            onPressed: onDelete,
          ),
        ]),
        const SizedBox(height: 12),

        // Progress bar
        Stack(children: [
          Container(height: 8, decoration: BoxDecoration(
            color: AppTheme.surface3, borderRadius: BorderRadius.circular(4),
          )),
          LayoutBuilder(builder: (context, c) => AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            height: 8,
            width: c.maxWidth * progress,
            decoration: BoxDecoration(
              color: isComplete ? AppTheme.accentAlt : AppTheme.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ]),
        const SizedBox(height: 8),

        Row(children: [
          Text('₹${goal.savedAmount.toStringAsFixed(0)} / ₹${goal.targetAmount.toStringAsFixed(0)}',
              style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          const Spacer(),
          Text('${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),

        if (!isComplete) ...[
          const SizedBox(height: 8),
          Row(children: [
            Text('${goal.monthsRemaining} months remaining • Need ₹${goal.requiredMonthlySaving.toStringAsFixed(0)}/mo',
                style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
            const Spacer(),
            GestureDetector(
              onTap: onAddAmount,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent, borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('+ Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
