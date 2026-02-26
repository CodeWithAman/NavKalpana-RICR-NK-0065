// CategoryPieChart widget
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> breakdown;
  const CategoryPieChart({super.key, required this.breakdown});

  static const _palette = [
    AppTheme.accent,
    AppTheme.accentAlt,
    AppTheme.warning,
    AppTheme.danger,
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final entries   = breakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent= breakdown.values.fold(0.0, (a, b) => a + b);

    return Column(children: [
      SizedBox(
        height: 220,
        child: PieChart(PieChartData(
          centerSpaceRadius: 60,
          sectionsSpace: 2,
          sections: List.generate(entries.length, (i) {
            final pct = totalSpent > 0 ? entries[i].value / totalSpent * 100 : 0;
            return PieChartSectionData(
              value: entries[i].value,
              color: _palette[i % _palette.length],
              radius: 24,
              showTitle: pct > 8,
              title: '${pct.toStringAsFixed(0)}%',
              titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            );
          }),
        )),
      ),
      const SizedBox(height: 8),
      Text('Total: ₹${totalSpent.toStringAsFixed(2)}',
          style: const TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      // Legend
      ...List.generate(entries.length, (i) {
        final pct = totalSpent > 0 ? entries[i].value / totalSpent * 100 : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: _palette[i % _palette.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(entries[i].key,
                style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w500))),
            Text('₹${entries[i].value.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _palette[i % _palette.length].withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${pct.toStringAsFixed(0)}%',
                  style: TextStyle(color: _palette[i % _palette.length], fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      }),
    ]);
  }
}
