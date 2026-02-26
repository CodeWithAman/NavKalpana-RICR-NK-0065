import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTimeRange selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  final List<Color> chartColors = [
    Colors.black,
    Colors.grey,
    Colors.blueGrey,
    Colors.deepPurple,
    Colors.teal,
    Colors.orange,
    Colors.indigo,
  ];

  // ================= RANGE PICKER =================

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );

    if (picked != null) {
      setState(() => selectedRange = picked);
    }
  }

  // ================= HELPERS =================

  DateTime get rangeStart => DateTime(
    selectedRange.start.year,
    selectedRange.start.month,
    selectedRange.start.day,
  );

  DateTime get rangeEnd => DateTime(
    selectedRange.end.year,
    selectedRange.end.month,
    selectedRange.end.day,
  ).add(const Duration(days: 1));

  List<DateTime> get daysInRange {
    final days = <DateTime>[];
    for (
      int i = 0;
      i <= selectedRange.end.difference(selectedRange.start).inDays;
      i++
    ) {
      days.add(selectedRange.start.add(Duration(days: i)));
    }
    return days.take(7).toList(); // 🔥 only 7 days
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Analytics",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: user == null
          ? const Center(child: Text("User not logged in"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _rangeSelector(),
                  const SizedBox(height: 20),
                  _categoryRing(user.uid),
                  const SizedBox(height: 32),
                  _dailyRangeBarChart(user.uid),
                ],
              ),
            ),
    );
  }

  // ================= RANGE SELECTOR =================

  Widget _rangeSelector() {
    return GestureDetector(
      onTap: _pickRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, size: 18),
            const SizedBox(width: 8),
            Text(
              "${DateFormat('dd MMM').format(selectedRange.start)} - "
              "${DateFormat('dd MMM').format(selectedRange.end)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORY RING =================

  Widget _categoryRing(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(rangeStart))
          .where('date', isLessThan: Timestamp.fromDate(rangeEnd))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyCard("No transactions in selected range");
        }

        final Map<String, double> totals = {};

        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totals[data['categoryName']] =
              (totals[data['categoryName']] ?? 0) +
              (data['amount'] ?? 0).toDouble();
        }

        final entries = totals.entries.toList();
        final totalSpent = totals.values.fold(0.0, (a, b) => a + b);

        return Column(
          children: [
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 55,
                  sections: List.generate(entries.length, (i) {
                    return PieChartSectionData(
                      value: entries[i].value,
                      color: chartColors[i % chartColors.length],
                      showTitle: false,
                      radius: 18,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Total Spent: ₹${totalSpent.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _legend(entries),
          ],
        );
      },
    );
  }

  // ================= DAILY BAR CHART (FIXED) =================

  Widget _dailyRangeBarChart(String uid) {
    final days = daysInRange;

    return FutureBuilder<List<QuerySnapshot>>(
      future: _fetchDailyDocs(uid, days),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _emptyCard("Loading...");
        }

        final Map<String, double> dailyTotals = {};

        for (final qs in snapshot.data!) {
          for (final doc in qs.docs) {
            final data = doc.data() as Map<String, dynamic>;
            dailyTotals[data['date']] = (data['spent'] ?? 0).toDouble();
          }
        }

        if (dailyTotals.isEmpty) {
          return _emptyCard("No daily data available");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Spending",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= days.length) {
                            return const SizedBox();
                          }
                          return Text(
                            DateFormat('dd MMM').format(days[i]),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(days.length, (i) {
                    final key = DateFormat('yyyy-MM-dd').format(days[i]);
                    final value = dailyTotals[key] ?? 0;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: Colors.black,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= FIRESTORE HELPER =================

  Future<List<QuerySnapshot>> _fetchDailyDocs(
    String uid,
    List<DateTime> days,
  ) async {
    final firestore = FirebaseFirestore.instance;

    final monthIds = days.map((d) => DateFormat('yyyy-MM').format(d)).toSet();

    final futures = <Future<QuerySnapshot>>[];

    for (final monthId in monthIds) {
      futures.add(
        firestore
            .collection('users')
            .doc(uid)
            .collection('analytics')
            .doc(monthId)
            .collection('daily')
            .get(),
      );
    }

    return Future.wait(futures);
  }

  // ================= LEGEND =================

  Widget _legend(List<MapEntry<String, double>> entries) {
    return Column(
      children: List.generate(entries.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: chartColors[i % chartColors.length],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entries[i].key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                "₹${entries[i].value.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================= EMPTY =================

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
