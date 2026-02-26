// =====================================================
// ExpenseProvider – manages expense state & Firestore
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  List<ExpenseModel> _expenses = [];
  bool _loading = false;
  String _searchQuery = '';
  String? _filterCategory;
  String _sortBy = 'date'; // 'date' | 'amount'

  List<ExpenseModel> get expenses => _filtered();
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  String? get filterCategory => _filterCategory;
  String get sortBy => _sortBy;

  String get _uid => _auth.currentUser?.uid ?? '';
  String get _monthId => DateFormat('yyyy-MM').format(DateTime.now());

  // ── Fetch expenses for current month ──────────────
  Stream<List<ExpenseModel>> streamMonthExpenses() {
    final start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final end   = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
    return _firestore
        .collection('users').doc(_uid).collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ExpenseModel.fromDoc).toList());
  }

  // ── Add expense ───────────────────────────────────
  Future<void> addExpense(ExpenseModel expense) async {
    _loading = true; notifyListeners();
    final batch = _firestore.batch();

    final dayId   = DateFormat('yyyy-MM-dd').format(expense.date);
    final monthId = DateFormat('yyyy-MM').format(expense.date);

    final expRef  = _firestore.collection('users').doc(_uid).collection('expenses').doc();
    final monthRef= _firestore.collection('users').doc(_uid).collection('analytics').doc(monthId);
    final dayRef  = monthRef.collection('daily').doc(dayId);

    batch.set(expRef, {
      ...expense.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update monthly aggregate
    batch.set(monthRef, {
      'month': monthId,
      'totalSpent': FieldValue.increment(expense.amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update daily aggregate
    batch.set(dayRef, {
      'date': dayId,
      'spent': FieldValue.increment(expense.amount),
    }, SetOptions(merge: true));

    // Update category breakdown
    final catRef = monthRef.collection('categories').doc(expense.categoryName);
    batch.set(catRef, {
      'name': expense.categoryName,
      'total': FieldValue.increment(expense.amount),
    }, SetOptions(merge: true));

    await batch.commit();
    _loading = false; notifyListeners();
  }

  // ── Edit expense ──────────────────────────────────
  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore
        .collection('users').doc(_uid)
        .collection('expenses').doc(expense.id)
        .update(expense.toMap());
    notifyListeners();
  }

  // ── Delete expense ────────────────────────────────
  Future<void> deleteExpense(ExpenseModel expense) async {
    final batch = _firestore.batch();
    final dayId   = DateFormat('yyyy-MM-dd').format(expense.date);
    final monthId = DateFormat('yyyy-MM').format(expense.date);

    final expRef  = _firestore.collection('users').doc(_uid).collection('expenses').doc(expense.id);
    final monthRef= _firestore.collection('users').doc(_uid).collection('analytics').doc(monthId);
    final dayRef  = monthRef.collection('daily').doc(dayId);

    batch.delete(expRef);
    batch.set(monthRef, {
      'totalSpent': FieldValue.increment(-expense.amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(dayRef, {
      'spent': FieldValue.increment(-expense.amount),
    }, SetOptions(merge: true));

    await batch.commit();
    notifyListeners();
  }

  // ── AI Text Parsing ───────────────────────────────
  // Parses strings like "Dinner at KFC 420" into components
  static Map<String, dynamic> parseExpenseText(String input) {
    final trimmed = input.trim();

    // Extract amount – last numeric token
    final numRegex = RegExp(r'(\d+(?:\.\d{1,2})?)');
    final allNums  = numRegex.allMatches(trimmed).toList();
    final amount   = allNums.isNotEmpty
        ? double.tryParse(allNums.last.group(0)!) ?? 0
        : 0.0;

    // Strip amount from string to get description
    final desc = trimmed.replaceAll(allNums.isNotEmpty ? allNums.last.group(0)! : '', '').trim();

    // Extract merchant using "at <name>" pattern
    final atRegex = RegExp(r'\bat\s+(\w+)', caseSensitive: false);
    final atMatch = atRegex.firstMatch(desc);
    final merchant = atMatch?.group(1);

    // Guess category from keywords
    final lower = desc.toLowerCase();
    String category = 'Other';
    if (_matchesKeywords(lower, ['food', 'dinner', 'lunch', 'breakfast', 'restaurant', 'kfc', 'mcd', 'zomato', 'swiggy'])) {
      category = 'Food';
    } else if (_matchesKeywords(lower, ['uber', 'ola', 'bus', 'metro', 'fuel', 'petrol', 'cab'])) {
      category = 'Transport';
    } else if (_matchesKeywords(lower, ['amazon', 'flipkart', 'shopping', 'bought', 'purchase'])) {
      category = 'Shopping';
    } else if (_matchesKeywords(lower, ['gym', 'fitness', 'yoga'])) {
      category = 'Gym';
    } else if (_matchesKeywords(lower, ['netflix', 'spotify', 'subscription', 'prime'])) {
      category = 'Subscription';
    } else if (_matchesKeywords(lower, ['medicine', 'hospital', 'doctor', 'pharmacy'])) {
      category = 'Health';
    } else if (_matchesKeywords(lower, ['rent', 'electricity', 'water', 'gas', 'bill'])) {
      category = 'Home';
    } else if (_matchesKeywords(lower, ['course', 'book', 'school', 'college', 'education'])) {
      category = 'Education';
    }

    return {
      'amount': amount,
      'category': category,
      'merchant': merchant ?? desc.split(' ').take(2).join(' '),
      'note': desc,
    };
  }

  static bool _matchesKeywords(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  // ── Filters & sorting ─────────────────────────────
  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setFilterCategory(String? cat) { _filterCategory = cat; notifyListeners(); }
  void setSortBy(String sort) { _sortBy = sort; notifyListeners(); }

  List<ExpenseModel> _filtered() {
    var list = List<ExpenseModel>.from(_expenses);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) =>
          e.categoryName.toLowerCase().contains(q) ||
          e.note.toLowerCase().contains(q)).toList();
    }
    if (_filterCategory != null) {
      list = list.where((e) => e.categoryName == _filterCategory).toList();
    }
    list.sort((a, b) =>
        _sortBy == 'amount'
            ? b.amount.compareTo(a.amount)
            : b.date.compareTo(a.date));
    return list;
  }
}
