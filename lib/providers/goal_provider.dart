// =====================================================
// GoalProvider – goal CRUD + auto allocation logic
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  final _fs   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<GoalModel> _goals = [];
  bool _loading = false;

  List<GoalModel> get goals => List.unmodifiable(_goals);
  bool get loading => _loading;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ── Stream goals ──────────────────────────────────
  Stream<List<GoalModel>> streamGoals() {
    return _fs.collection('users').doc(_uid).collection('goals')
        .orderBy('priority')
        .snapshots()
        .map((s) => s.docs.map(GoalModel.fromDoc).toList());
  }

  // ── Add goal ──────────────────────────────────────
  Future<void> addGoal(GoalModel goal) async {
    await _fs.collection('users').doc(_uid).collection('goals').add({
      ...goal.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  // ── Update saved amount ───────────────────────────
  Future<void> addToGoal(String goalId, double amount) async {
    await _fs.collection('users').doc(_uid).collection('goals').doc(goalId).update({
      'savedAmount': FieldValue.increment(amount),
    });
    notifyListeners();
  }

  // ── Delete goal ───────────────────────────────────
  Future<void> deleteGoal(String goalId) async {
    await _fs.collection('users').doc(_uid).collection('goals').doc(goalId).delete();
    notifyListeners();
  }

  // ── Auto Allocation ───────────────────────────────
  // Surplus = Income − Essential Expenses
  // Distribute based on priority weights and financial stability
  Map<String, double> computeAllocations({
    required double surplus,
    required List<GoalModel> goals,
    required double stabilityFactor, // 0–1 (higher = more aggressive allocation)
  }) {
    if (goals.isEmpty || surplus <= 0) return {};

    // Effective surplus after stability adjustment
    final effectiveSurplus = surplus * (0.5 + stabilityFactor * 0.5);

    // Priority weight: priority 1 gets more, higher number = lower weight
    final maxPriority = goals.map((g) => g.priority).reduce((a, b) => a > b ? a : b);
    double totalWeight = 0;
    final weights = <String, double>{};
    for (final g in goals) {
      final w = (maxPriority - g.priority + 1).toDouble();
      weights[g.id] = w;
      totalWeight += w;
    }

    final result = <String, double>{};
    for (final g in goals) {
      if (g.progress < 1) {
        final share = effectiveSurplus * (weights[g.id]! / totalWeight);
        // Cap at what's needed
        final needed = g.targetAmount - g.savedAmount;
        result[g.id] = share.clamp(0, needed);
      }
    }
    return result;
  }
}
