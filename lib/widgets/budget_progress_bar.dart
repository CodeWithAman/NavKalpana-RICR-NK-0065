// BudgetProgressBar widget
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BudgetProgressBar extends StatelessWidget {
  final double spent, budget;
  final String symbol;
  final bool light; // true = white labels (for colored background)

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.budget,
    this.symbol = '₹',
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct   = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final pctN  = (pct * 100).toStringAsFixed(0);
    final overBudget  = spent > budget && budget > 0;
    final warn90      = pct >= 0.9 && !overBudget;
    final warn75      = pct >= 0.75 && !warn90;

    Color barColor;
    if (overBudget)  barColor = AppTheme.danger;
    else if (warn90) barColor = AppTheme.danger.withOpacity(0.8);
    else if (warn75) barColor = AppTheme.warning;
    else             barColor = AppTheme.accentAlt;

    final labelColor = light ? Colors.white : AppTheme.textPri;
    final secColor   = light ? Colors.white70 : AppTheme.textSec;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('$symbol${spent.toStringAsFixed(0)} spent',
            style: TextStyle(color: labelColor, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('$pctN% used', style: TextStyle(color: secColor, fontSize: 12)),
      ]),
      const SizedBox(height: 8),
      Stack(children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: light ? Colors.white24 : AppTheme.surface3,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          height: 10,
          width: constraints.maxWidth * pct,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(5),
          ),
        )),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        Text('Budget: $symbol${budget.toStringAsFixed(0)}', style: TextStyle(color: secColor, fontSize: 12)),
        const Spacer(),
        Text(overBudget
            ? '🚨 Over by $symbol${(spent - budget).toStringAsFixed(0)}'
            : 'Left: $symbol${(budget - spent).toStringAsFixed(0)}',
            style: TextStyle(
                color: overBudget ? AppTheme.danger : secColor, fontSize: 12)),
      ]),
    ]);
  }
}
