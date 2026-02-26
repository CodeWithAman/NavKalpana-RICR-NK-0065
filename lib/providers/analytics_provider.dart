// =====================================================
// AnalyticsProvider – predictive intelligence + insights
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/user_stats_model.dart';

class Insight {
  final String title;
  final String body;
  final String type; // 'info' | 'warning' | 'danger' | 'success'
  const Insight({required this.title, required this.body, required this.type});
}

class AnalyticsProvider extends ChangeNotifier {
  final _fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  UserStatsModel _stats = UserStatsModel.empty();
  List<Insight> _insights = [];
  List<Map<String, double>> _monthlyTrends = []; // last 6 months totals
  double _projectedMonthEnd = 0;
  bool _loading = false;

  UserStatsModel get stats => _stats;
  List<Insight> get insights => _insights;
  List<Map<String, double>> get monthlyTrends => _monthlyTrends;
  double get projectedMonthEnd => _projectedMonthEnd;
  bool get loading => _loading;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ── Load current month analytics ─────────────────
  Future<void> loadAnalytics({
    required double income,
    required double budget,
  }) async {
    _loading = true;
    notifyListeners();

    final now = DateTime.now();
    final monthId = DateFormat('yyyy-MM').format(now);

    try {
      // Fetch expenses for current month
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);

      final snap = await _fs
          .collection('users')
          .doc(_uid)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .get();

      final expenses = snap.docs.map(ExpenseModel.fromDoc).toList();

      // Category breakdown
      final catBreakdown = <String, double>{};
      for (final e in expenses) {
        catBreakdown[e.categoryName] =
            (catBreakdown[e.categoryName] ?? 0) + e.amount;
      }

      final totalSpent = catBreakdown.values.fold(0.0, (a, b) => a + b);

      // Savings rate
      final savingsRate = income > 0
          ? (((income - totalSpent) / income).clamp(0.0, 1.0)).toDouble()
          : 0.0;
      // Budget discipline (0–1)
      final budgetDiscipline = budget > 0
          ? ((1 - (totalSpent / budget)).clamp(0.0, 1.0)).toDouble()
          : 0.0;

      // Spending stability (based on daily variance)
      final dailySpend = _computeDailySpend(expenses, now);
      final stability = _computeStability(dailySpend);

      // Diversification (number of categories / ideal 5)
      final diversification = ((catBreakdown.length / 5).clamp(
        0.0,
        1.0,
      )).toDouble();
      final healthScore = UserStatsModel.computeHealthScore(
        budgetDiscipline: budgetDiscipline,
        savingsRatio: savingsRate,
        spendingStability: stability,
        diversification: diversification,
      );

      // Overspend count
      final overspendCount = budget > 0 && totalSpent > budget ? 1 : 0;

      final riskLevel = UserStatsModel.computeRisk(
        budgetUsedPct: budget > 0 ? totalSpent / budget * 100 : 0,
        volatilityScore: 1 - stability,
        overspendCount: overspendCount,
        savingsRate: savingsRate,
      );

      final personality = UserStatsModel.detectPersonality(
        savingsRate: savingsRate,
        budgetAdherence: budgetDiscipline,
        volatility: 1 - stability,
      );

      _stats = UserStatsModel(
        monthlyIncome: income,
        monthlyExpense: totalSpent,
        monthlyBudget: budget,
        savingsRate: savingsRate,
        healthScore: healthScore,
        riskLevel: riskLevel,
        spendingPersonality: personality,
        categoryBreakdown: catBreakdown,
      );

      // Projected month-end spend
      final daysElapsed = now.day;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      _projectedMonthEnd = daysElapsed > 0
          ? (totalSpent / daysElapsed) * daysInMonth
          : 0;

      // Load last 6 months trends
      await _loadTrends();

      // Generate insights
      _insights = _generateInsights(
        catBreakdown: catBreakdown,
        totalSpent: totalSpent,
        income: income,
        budget: budget,
        expenses: expenses,
        savingsRate: savingsRate,
      );
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  // ── Daily spend map ───────────────────────────────
  Map<int, double> _computeDailySpend(
    List<ExpenseModel> expenses,
    DateTime now,
  ) {
    final map = <int, double>{};
    for (final e in expenses) {
      map[e.date.day] = (map[e.date.day] ?? 0) + e.amount;
    }
    return map;
  }

  // ── Stability score 0–1 ───────────────────────────
  // Low variance = high stability
  double _computeStability(Map<int, double> daily) {
    if (daily.isEmpty) return 0.5;
    final values = daily.values.toList();
    final mean = values.fold(0.0, (a, b) => a + b) / values.length;
    if (mean == 0) return 1.0;
    final variance =
        values.fold(0.0, (a, b) => a + (b - mean) * (b - mean)) / values.length;
    final stdDev = (variance < 0 ? 0 : variance).toDouble();
    final cv = stdDev.isNaN ? 0 : (mean > 0 ? stdDev / mean : 0);
    return (1 - cv.clamp(0.0, 1.0)).toDouble();
  }

  // ── Load 6-month trend ────────────────────────────
  Future<void> _loadTrends() async {
    final now = DateTime.now();
    _monthlyTrends = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthId = DateFormat('yyyy-MM').format(month);
      final snap = await _fs
          .collection('users')
          .doc(_uid)
          .collection('analytics')
          .doc(monthId)
          .get();
      final total = snap.exists
          ? ((snap.data() as Map)['totalSpent'] ?? 0).toDouble()
          : 0.0;
      _monthlyTrends.add({'month': month.month.toDouble(), 'total': total});
    }
  }

  // ── Month-over-month % change ─────────────────────
  double get monthOverMonthChange {
    if (_monthlyTrends.length < 2) return 0;
    final current = _monthlyTrends.last['total']!;
    final previous = _monthlyTrends[_monthlyTrends.length - 2]['total']!;
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  // ── AI Insight generation ─────────────────────────
  List<Insight> _generateInsights({
    required Map<String, double> catBreakdown,
    required double totalSpent,
    required double income,
    required double budget,
    required List<ExpenseModel> expenses,
    required double savingsRate,
  }) {
    final list = <Insight>[];

    // 1. Food > 30% of spend
    final foodTotal = catBreakdown['Food'] ?? catBreakdown['Groceries'] ?? 0;
    final foodPct = totalSpent > 0 ? foodTotal / totalSpent * 100 : 0;
    if (foodPct > 30) {
      list.add(
        Insight(
          title: 'High Food Spending',
          body:
              'Food & groceries account for ${foodPct.toStringAsFixed(0)}% of your expenses. '
              'Consider meal planning to reduce costs.',
          type: 'warning',
        ),
      );
    }

    // 2. Low savings rate
    if (savingsRate < 0.10 && income > 0) {
      list.add(
        Insight(
          title: 'Low Savings Rate',
          body:
              'You are saving ${(savingsRate * 100).toStringAsFixed(0)}% of your income. '
              'Aim for at least 20% for financial health.',
          type: 'danger',
        ),
      );
    }

    // 3. Category concentration > 40%
    catBreakdown.forEach((cat, amount) {
      final pct = totalSpent > 0 ? amount / totalSpent * 100 : 0;
      if (pct > 40) {
        list.add(
          Insight(
            title: 'High Concentration: $cat',
            body:
                '${pct.toStringAsFixed(0)}% of your spending is on $cat. '
                'Diversify your expense categories.',
            type: 'warning',
          ),
        );
      }
    });

    // 4. Subscription detection (same amount, same merchant, multiple months)
    final merchantCounts = <String, int>{};
    for (final e in expenses) {
      if (e.merchant != null) {
        merchantCounts[e.merchant!] = (merchantCounts[e.merchant!] ?? 0) + 1;
      }
    }
    final subs = merchantCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key);
    if (subs.isNotEmpty) {
      list.add(
        Insight(
          title: 'Subscriptions Detected',
          body:
              'Recurring charges from: ${subs.join(', ')}. Review and cancel unused ones.',
          type: 'info',
        ),
      );
    }

    // 5. Weekend vs weekday
    final weekendTotal = expenses
        .where((e) => e.date.weekday >= 6)
        .fold(0.0, (a, b) => a + b.amount);
    final weekdayTotal = expenses
        .where((e) => e.date.weekday < 6)
        .fold(0.0, (a, b) => a + b.amount);
    final weekendCount = expenses.where((e) => e.date.weekday >= 6).length;
    final weekdayCount = expenses.where((e) => e.date.weekday < 6).length;
    if (weekendCount > 0 && weekdayCount > 0) {
      final weekendAvg = weekendTotal / weekendCount;
      final weekdayAvg = weekdayTotal / weekdayCount;
      if (weekendAvg > weekdayAvg * 1.5) {
        list.add(
          Insight(
            title: 'Weekend Spending Spike',
            body:
                'Your weekend daily spend (₹${weekendAvg.toStringAsFixed(0)}) is '
                '${((weekendAvg / weekdayAvg - 1) * 100).toStringAsFixed(0)}% higher than weekdays.',
            type: 'info',
          ),
        );
      }
    }

    // 6. Budget on track
    if (budget > 0 && totalSpent < budget * 0.75) {
      list.add(
        Insight(
          title: 'Budget on Track 🎉',
          body:
              'You have used only ${(totalSpent / budget * 100).toStringAsFixed(0)}% of your budget. Keep it up!',
          type: 'success',
        ),
      );
    }

    // Sort: danger > warning > info > success
    final order = {'danger': 0, 'warning': 1, 'info': 2, 'success': 3};
    list.sort((a, b) => (order[a.type] ?? 4).compareTo(order[b.type] ?? 4));

    return list;
  }
}
