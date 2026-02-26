// ExpenseListScreen – list with search, filter, sort

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../screens/add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchCtrl = TextEditingController();
  String? _filterCat;
  String _sortBy = 'date'; // 'date' | 'amount'
  DateTimeRange _range = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<ExpenseModel>> get _stream {
    final start = DateTime(_range.start.year, _range.start.month, _range.start.day);
    final end   = DateTime(_range.end.year, _range.end.month, _range.end.day)
        .add(const Duration(days: 1));
    return FirebaseFirestore.instance
        .collection('users').doc(_uid).collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ExpenseModel.fromDoc).toList());
  }

  List<ExpenseModel> _applyFilters(List<ExpenseModel> all) {
    var list = all;
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      list = list.where((e) =>
          e.categoryName.toLowerCase().contains(q) ||
          e.note.toLowerCase().contains(q)).toList();
    }
    if (_filterCat != null) {
      list = list.where((e) => e.categoryName == _filterCat).toList();
    }
    if (_sortBy == 'amount') {
      list.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return list;
  }

  Future<void> _deleteExpense(ExpenseModel e) async {
    final batch = FirebaseFirestore.instance.batch();
    final dayId   = DateFormat('yyyy-MM-dd').format(e.date);
    final monthId = DateFormat('yyyy-MM').format(e.date);
    final base    = FirebaseFirestore.instance.collection('users').doc(_uid);

    batch.delete(base.collection('expenses').doc(e.id));
    batch.set(base.collection('analytics').doc(monthId), {
      'totalSpent': FieldValue.increment(-e.amount),
    }, SetOptions(merge: true));
    batch.set(base.collection('analytics').doc(monthId).collection('daily').doc(dayId), {
      'spent': FieldValue.increment(-e.amount),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.accent),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
          ),
        ],
      ),
      body: Column(children: [
        _SearchBar(controller: _searchCtrl, onChanged: (_) => setState(() {})),
        _FilterBar(
          filterCat: _filterCat,
          sortBy: _sortBy,
          range: _range,
          onCategoryChanged: (c) => setState(() => _filterCat = c),
          onSortChanged: (s) => setState(() => _sortBy = s),
          onRangeChanged: (r) => setState(() => _range = r),
        ),
        Expanded(
          child: StreamBuilder<List<ExpenseModel>>(
            stream: _stream,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
              }
              final list = _applyFilters(snap.data!);
              if (list.isEmpty) {
                return const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long, color: AppTheme.textDim, size: 48),
                    SizedBox(height: 12),
                    Text('No expenses found', style: TextStyle(color: AppTheme.textSec)),
                  ]),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _ExpenseTile(
                  expense: list[i],
                  onDelete: () => _deleteExpense(list[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPri),
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.textSec),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSec),
                onPressed: () { controller.clear(); onChanged(''); },
              )
            : null,
      ),
    ),
  );
}

class _FilterBar extends StatelessWidget {
  final String? filterCat;
  final String sortBy;
  final DateTimeRange range;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<DateTimeRange> onRangeChanged;
  const _FilterBar({
    required this.filterCat, required this.sortBy, required this.range,
    required this.onCategoryChanged, required this.onSortChanged, required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Date range chip
          _Chip(
            label: '${DateFormat('dd MMM').format(range.start)} – ${DateFormat('dd MMM').format(range.end)}',
            icon: Icons.date_range,
            active: true,
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: range,
              );
              if (picked != null) onRangeChanged(picked);
            },
          ),
          const SizedBox(width: 8),
          // Sort chip
          _Chip(
            label: sortBy == 'date' ? 'By Date' : 'By Amount',
            icon: Icons.sort,
            active: false,
            onTap: () => onSortChanged(sortBy == 'date' ? 'amount' : 'date'),
          ),
          const SizedBox(width: 8),
          // Category filter
          ...CategoryModel.defaults.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: cat.name,
              active: filterCat == cat.name,
              onTap: () => onCategoryChanged(filterCat == cat.name ? null : cat.name),
            ),
          )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap; final IconData? icon;
  const _Chip({required this.label, required this.active, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppTheme.accent : AppTheme.surface3,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: active ? Colors.white : AppTheme.textSec), const SizedBox(width: 4)],
        Text(label, style: TextStyle(
            color: active ? Colors.white : AppTheme.textSec, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;
  const _ExpenseTile({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: AppTheme.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface3, borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(expense.categoryName,
                style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(expense.note.isNotEmpty
                    ? expense.note
                    : DateFormat('dd MMM, hh:mm a').format(expense.date),
                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('-₹${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
            if (expense.isRecurring)
              const Text('Recurring', style: TextStyle(color: AppTheme.warning, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}
