import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/analytics_provider.dart';
import '../widgets/category_pie_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _RangePicker(range: _range, onChanged: (r) => setState(() => _range = r)),
          const SizedBox(height: 20),

          // ── Month-over-month summary ───────────────
          _MomSummary(change: analytics.monthOverMonthChange),
          const SizedBox(height: 20),

          // ── Category pie ──────────────────────────
          const Text('Spending by Category',
              style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          _CategoryRing(uid: _uid, range: _range),
          const SizedBox(height: 20),

          // ── 6-month trend bar ─────────────────────
          const Text('6-Month Trend',
              style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          _TrendBar(trends: analytics.monthlyTrends),
          const SizedBox(height: 20),

          // ── Daily bar within range ─────────────────
          const Text('Daily Spending',
              style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          _DailyBar(uid: _uid, range: _range),
        ]),
      ),
    );
  }
}

//Range picker

class _RangePicker extends StatelessWidget {
  final DateTimeRange range;
  final ValueChanged<DateTimeRange> onChanged;
  const _RangePicker({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final picked = await showDateRangePicker(
        context: context, firstDate: DateTime(2020), lastDate: DateTime.now(),
        initialDateRange: range,
      );
      if (picked != null) onChanged(picked);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface3, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        const Icon(Icons.date_range, color: AppTheme.accent, size: 18),
        const SizedBox(width: 10),
        Text('${DateFormat('dd MMM').format(range.start)} – ${DateFormat('dd MMM').format(range.end)}',
            style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
        const Spacer(),
        const Icon(Icons.expand_more, color: AppTheme.textSec),
      ]),
    ),
  );
}

// Month-over-month summary

class _MomSummary extends StatelessWidget {
  final double change;
  const _MomSummary({required this.change});

  @override
  Widget build(BuildContext context) {
    final isPos = change >= 0;
    final color = isPos ? AppTheme.danger : AppTheme.accentAlt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(isPos ? Icons.trending_up : Icons.trending_down, color: color),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Month-over-Month Change',
              style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
          Text('${isPos ? '+' : ''}${change.toStringAsFixed(1)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 22)),
        ])),
        Text(isPos ? 'Spending up' : 'Spending down',
            style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}

//Category ring

class _CategoryRing extends StatelessWidget {
  final String uid;
  final DateTimeRange range;
  const _CategoryRing({required this.uid, required this.range});

  @override
  Widget build(BuildContext context) {
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end   = DateTime(range.end.year, range.end.month, range.end.day).add(const Duration(days: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(uid).collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _empty('No data in selected range');
        }
        final breakdown = <String, double>{};
        for (final doc in snap.data!.docs) {
          final d = doc.data() as Map<String, dynamic>;
          breakdown[d['categoryName']] = (breakdown[d['categoryName']] ?? 0) + (d['amount'] ?? 0).toDouble();
        }
        return CategoryPieChart(breakdown: breakdown);
      },
    );
  }

  Widget _empty(String msg) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border)),
    child: Center(child: Text(msg, style: const TextStyle(color: AppTheme.textSec))),
  );
}

// ── 6-month trend bar ─────────────────────────────────

class _TrendBar extends StatelessWidget {
  final List<Map<String, double>> trends;
  const _TrendBar({required this.trends});

  static const _monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) return const SizedBox();
    final maxVal = trends.map((t) => t['total']!).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(BarChartData(
          backgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= trends.length) return const SizedBox();
                final month = trends[i]['month']!.toInt() - 1;
                return Padding(padding: const EdgeInsets.only(top: 6),
                    child: Text(_monthNames[month.clamp(0,11)],
                        style: const TextStyle(color: AppTheme.textSec, fontSize: 11)));
              },
            )),
          ),
          barGroups: List.generate(trends.length, (i) {
            final v = trends[i]['total']!;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: v,
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, Color(0xFF3B82F6)],
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ]);
          }),
          maxY: maxVal > 0 ? maxVal * 1.2 : 100,
        )),
      ),
    );
  }
}

//Daily bar within range

class _DailyBar extends StatelessWidget {
  final String uid;
  final DateTimeRange range;
  const _DailyBar({required this.uid, required this.range});

  List<DateTime> get _days {
    final days = <DateTime>[];
    int count = range.end.difference(range.start).inDays + 1;
    for (int i = 0; i < count.clamp(0, 30); i++) {
      days.add(range.start.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final monthIds = days.map((d) => DateFormat('yyyy-MM').format(d)).toSet();

    return FutureBuilder<Map<String, double>>(
      future: _fetchDailyTotals(monthIds),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
        }
        final data = snap.data!;
        final maxVal = data.values.isEmpty ? 100.0
            : data.values.reduce((a, b) => a > b ? a : b);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              backgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: days.length <= 14,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= days.length) return const SizedBox();
                    return Padding(padding: const EdgeInsets.only(top: 4),
                        child: Text('${days[i].day}',
                            style: const TextStyle(color: AppTheme.textSec, fontSize: 10)));
                  },
                )),
              ),
              barGroups: List.generate(days.length, (i) {
                final key = DateFormat('yyyy-MM-dd').format(days[i]);
                final v   = data[key] ?? 0;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: v, color: AppTheme.accentAlt, width: days.length > 14 ? 6 : 10,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]);
              }),
              maxY: maxVal > 0 ? maxVal * 1.2 : 100,
            )),
          ),
        );
      },
    );
  }

  Future<Map<String, double>> _fetchDailyTotals(Set<String> monthIds) async {
    final result = <String, double>{};
    for (final mid in monthIds) {
      final snap = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('analytics')
          .doc(mid).collection('daily').get();
      for (final doc in snap.docs) {
        final d = doc.data();
        result[d['date'] as String] = (d['spent'] ?? 0).toDouble();
      }
    }
    return result;
  }
}
