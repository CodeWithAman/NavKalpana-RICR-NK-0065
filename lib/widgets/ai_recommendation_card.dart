// AiRecommendationCard widget
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/analytics_provider.dart';

class AiRecommendationCard extends StatelessWidget {
  final Insight insight;
  const AiRecommendationCard({super.key, required this.insight});

  static const _colors = {
    'danger':  AppTheme.danger,
    'warning': AppTheme.warning,
    'info':    AppTheme.accent,
    'success': AppTheme.accentAlt,
  };

  static const _icons = {
    'danger':  Icons.error_outline,
    'warning': Icons.warning_amber_rounded,
    'info':    Icons.lightbulb_outline,
    'success': Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[insight.type] ?? AppTheme.textSec;
    final icon  = _icons[insight.type] ?? Icons.info_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(insight.title,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(insight.body,
              style: const TextStyle(color: AppTheme.textSec, fontSize: 13, height: 1.4)),
        ])),
      ]),
    );
  }
}
