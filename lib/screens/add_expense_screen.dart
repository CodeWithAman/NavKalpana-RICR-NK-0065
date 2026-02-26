// =====================================================
// AddExpenseScreen – AI text parsing + manual entry
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? preselectedCategory;
  const AddExpenseScreen({super.key, this.preselectedCategory});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Manual entry ──────────────────────────────────
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _saving = false;

  // ── AI text parsing ───────────────────────────────
  final _aiCtrl     = TextEditingController();
  Map<String, dynamic>? _parsedResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = widget.preselectedCategory;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _aiCtrl.dispose();
    super.dispose();
  }

  // ── Save expense ──────────────────────────────────
  Future<void> _save({double? amount, String? category, String? note, String? merchant}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final a = amount ?? double.tryParse(_amountCtrl.text);
    final c = category ?? _selectedCategory;
    if (a == null || a <= 0 || c == null) {
      _showError('Please fill amount and category');
      return;
    }
    setState(() => _saving = true);
    try {
      final expense = ExpenseModel(
        id: '',
        amount: a,
        categoryName: c,
        note: note ?? _noteCtrl.text.trim(),
        date: _selectedDate,
        isRecurring: _isRecurring,
        merchant: merchant,
      );
      await ExpenseProvider().addExpense(expense);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('Failed to save expense');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
    );
  }

  // ── Parse AI text ──────────────────────────────────
  void _parseAi() {
    if (_aiCtrl.text.trim().isEmpty) return;
    setState(() {
      _parsedResult = ExpenseProvider.parseExpenseText(_aiCtrl.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Add Expense'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSec,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'Manual'),
            Tab(icon: Icon(Icons.smart_toy, size: 14), text: 'AI Parse'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_manualTab(), _aiTab()],
      ),
    );
  }

  // ── Manual tab ────────────────────────────────────
  Widget _manualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _label('Amount'),
        const SizedBox(height: 8),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppTheme.textPri, fontSize: 28, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(prefixText: '₹  ', hintText: '0.00'),
        ),
        const SizedBox(height: 20),
        _label('Category'),
        const SizedBox(height: 8),
        _CategoryGrid(
          selected: _selectedCategory,
          onSelect: (c) => setState(() => _selectedCategory = c),
        ),
        const SizedBox(height: 20),
        _label('Note'),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl,
          style: const TextStyle(color: AppTheme.textPri),
          decoration: const InputDecoration(hintText: 'Add a note (optional)'),
        ),
        const SizedBox(height: 16),
        _DateRow(
          date: _selectedDate,
          onChanged: (d) => setState(() => _selectedDate = d),
        ),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Recurring', style: TextStyle(color: AppTheme.textPri)),
          const Spacer(),
          Switch(value: _isRecurring, onChanged: (v) => setState(() => _isRecurring = v)),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : () => _save(),
            child: _saving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Expense', style: TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }

  // ── AI parse tab ──────────────────────────────────
  Widget _aiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
          ),
          child: const Row(children: [
            Icon(Icons.smart_toy, color: AppTheme.accent, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Type a natural sentence like "Dinner at KFC 420" and AI will auto-extract the details.',
              style: TextStyle(color: AppTheme.textSec, fontSize: 13),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _aiCtrl,
          style: const TextStyle(color: AppTheme.textPri),
          decoration: InputDecoration(
            hintText: 'e.g. "Coffee at Starbucks 280"',
            suffixIcon: IconButton(
              icon: const Icon(Icons.auto_fix_high, color: AppTheme.accent),
              onPressed: _parseAi,
            ),
          ),
          onSubmitted: (_) => _parseAi(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.accent),
            label: const Text('Parse with AI', style: TextStyle(color: AppTheme.accent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _parseAi,
          ),
        ),

        if (_parsedResult != null) ...[
          const SizedBox(height: 24),
          const Text('Extracted Details', style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          _ParsedResultCard(result: _parsedResult!),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirm & Save'),
              onPressed: _saving ? null : () => _save(
                amount: _parsedResult!['amount'],
                category: _parsedResult!['category'],
                note: _parsedResult!['note'],
                merchant: _parsedResult!['merchant'],
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppTheme.textSec, fontSize: 12, fontWeight: FontWeight.w600));
}

// ── Parsed result card ────────────────────────────────

class _ParsedResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ParsedResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentAlt.withOpacity(0.4)),
      ),
      child: Column(children: [
        _row('Amount', '₹${(result['amount'] ?? 0).toStringAsFixed(2)}', AppTheme.accentAlt),
        const Divider(color: AppTheme.border),
        _row('Category', result['category'] ?? '—', AppTheme.textPri),
        const Divider(color: AppTheme.border),
        _row('Merchant', result['merchant'] ?? '—', AppTheme.textPri),
        const Divider(color: AppTheme.border),
        _row('Note', result['note'] ?? '—', AppTheme.textSec),
      ]),
    );
  }

  Widget _row(String label, String value, Color valueColor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
      const Spacer(),
      Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}

// ── Category grid ─────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _CategoryGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cats = CategoryModel.defaults;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.8,
      ),
      itemBuilder: (_, i) {
        final cat    = cats[i];
        final active = selected == cat.name;
        return GestureDetector(
          onTap: () => onSelect(cat.name),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: active ? AppTheme.accent : AppTheme.surface3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
              ),
              child: Icon(cat.icon, color: active ? Colors.white : AppTheme.textSec, size: 20),
            ),
            const SizedBox(height: 4),
            Text(cat.name, style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textSec,
                fontSize: 9, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        );
      },
    );
  }
}

// ── Date row ──────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DateRow({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.accent, surface: AppTheme.surface2),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface3,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today, color: AppTheme.textSec, size: 18),
          const SizedBox(width: 12),
          Text(DateFormat('dd MMMM yyyy').format(date),
              style: const TextStyle(color: AppTheme.textPri)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppTheme.textSec),
        ]),
      ),
    );
  }
}
