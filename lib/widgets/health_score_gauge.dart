// HealthScoreGauge widget – semicircle arc gauge
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthScoreGauge extends StatelessWidget {
  final double score; // 0–100
  final double size;

  const HealthScoreGauge({super.key, required this.score, this.size = 100});

  Color get _color {
    if (score >= 75) return AppTheme.accentAlt;
    if (score >= 50) return AppTheme.accent;
    if (score >= 25) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(score: score, color: _color),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(score.toStringAsFixed(0),
                style: TextStyle(color: _color, fontSize: size * 0.22, fontWeight: FontWeight.w800)),
            Text('/ 100', style: TextStyle(color: AppTheme.textDim, fontSize: size * 0.1)),
          ]),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;
  const _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const startAngle = -math.pi * 1.25;
    const sweepAngle = math.pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = AppTheme.surface3
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * (score / 100).clamp(0, 1), false, fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.score != score || old.color != color;
}

// ── Risk indicator badge ──────────────────────────────

class RiskIndicatorBadge extends StatelessWidget {
  final String level; // 'Low' | 'Moderate' | 'High'
  const RiskIndicatorBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = {'Low': AppTheme.accentAlt, 'Moderate': AppTheme.warning, 'High': AppTheme.danger};
    final icons  = {'Low': Icons.check_circle, 'Moderate': Icons.warning_amber, 'High': Icons.error};
    final color  = colors[level] ?? AppTheme.textSec;
    final icon   = icons[level] ?? Icons.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text('$level Risk', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }
}
