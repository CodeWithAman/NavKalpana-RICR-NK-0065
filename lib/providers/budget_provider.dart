// =====================================================
// BudgetProvider – monthly budget + category limits
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class BudgetAlert {
  final String message;
  final String level; // 'warn75' | 'warn90' | 'over' | 'predictive'
  const BudgetAlert({required this.message, required this.level});
}

class BudgetProvider extends ChangeNotifier {
  final _fs  = FirebaseFirestore.instance;
  final _auth= FirebaseAuth.instance;

  double _monthlyBudget = 0;
  double _monthlySpent  = 0;
  Map<String, double> _categoryLimits = {};
  Map<String, double> _categorySpent  = {};

  double get monthlyBudget => _monthlyBudget;
  double get monthlySpent  => _monthlySpent;
  double get budgetUsedPct =>
      _monthlyBudget > 0 ? (_monthlySpent / _monthlyBudget * 100).clamp(0, 200) : 0;
  double get remaining     => (_monthlyBudget - _monthlySpent).clamp(0, _monthlyBudget);
  Map<String, double> get categoryLimits => _categoryLimits;
  Map<String, double> get categorySpent  => _categorySpent;

  String get _uid    => _auth.currentUser?.uid ?? '';
  String get _monthId=> DateFormat('yyyy-MM').format(DateTime.now());

  // ── Stream combined budget state ─────────────────
  Stream<Map<String, dynamic>> streamBudget() {
    return _fs.collection('users').doc(_uid).snapshots().map((snap) {
      final d = snap.data() ?? {};
      return {
        'monthlyBudget': (d['monthlyBudget'] ?? 0).toDouble(),
      };
    });
  }

  void updateFromData({required double budget, required double spent}) {
    _monthlyBudget = budget;
    _monthlySpent  = spent;
    notifyListeners();
  }

  // ── Save monthly budget ───────────────────────────
  Future<void> setMonthlyBudget(double amount) async {
    await _fs.collection('users').doc(_uid).update({'monthlyBudget': amount});
    await _fs.collection('users').doc(_uid).collection('budgets').doc(_monthId).set({
      'month': _monthId,
      'totalBudget': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _monthlyBudget = amount;
    notifyListeners();
  }

  // ── Set category limit ────────────────────────────
  Future<void> setCategoryLimit(String category, double limit) async {
    await _fs.collection('users').doc(_uid)
        .collection('budgets').doc(_monthId)
        .collection('categories').doc(category)
        .set({'limit': limit}, SetOptions(merge: true));
    _categoryLimits[category] = limit;
    notifyListeners();
  }

  // ── Compute smart alerts ──────────────────────────
  List<BudgetAlert> get alerts {
    final list = <BudgetAlert>[];
    final pct = budgetUsedPct;

    if (pct >= 100) {
      list.add(const BudgetAlert(message: '🚨 Monthly budget exceeded!', level: 'over'));
    } else if (pct >= 90) {
      list.add(BudgetAlert(
        message: '⚠️ 90% of budget used. Only ₹${remaining.toStringAsFixed(0)} left.',
        level: 'warn90',
      ));
    } else if (pct >= 75) {
      list.add(BudgetAlert(
        message: '💡 75% of budget used. Monitor spending.',
        level: 'warn75',
      ));
    }

    // Predictive: project month-end spend based on daily velocity
    final today = DateTime.now();
    final daysElapsed = today.day;
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    if (daysElapsed > 3 && _monthlyBudget > 0) {
      final velocity     = _monthlySpent / daysElapsed;       // ₹/day
      final projected    = velocity * daysInMonth;
      final projectedPct = projected / _monthlyBudget * 100;
      if (projectedPct > 110) {
        list.add(BudgetAlert(
          message:
              '📊 Projected month-end spend: ₹${projected.toStringAsFixed(0)} '
              '(${projectedPct.toStringAsFixed(0)}% of budget).',
          level: 'predictive',
        ));
      }
    }

    // Category alerts
    for (final entry in _categoryLimits.entries) {
      final spent = _categorySpent[entry.key] ?? 0;
      final catPct= entry.value > 0 ? (spent / entry.value * 100) : 0;
      if (catPct >= 100) {
        list.add(BudgetAlert(
          message: '🔴 ${entry.key} limit exceeded!',
          level: 'over',
        ));
      }
    }

    return list;
  }
}
