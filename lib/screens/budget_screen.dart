// BudgetScreen – set budget, category limits, alerts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/category_model.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_progress_bar.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetCtrl = TextEditingController();
  bool _editingBudget = false;

  String get _uid   => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _month => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Budget')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users').doc(_uid).collection('analytics').doc(_month).snapshots(),
        builder: (context, snap) {
          final spent = snap.hasData && snap.data!.exists
              ? ((snap.data!.data() as Map)['totalSpent'] ?? 0).toDouble() : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Monthly budget card ────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, Color(0xFF3B82F6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Monthly Budget', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('₹${budget.monthlyBudget.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () {
                        _budgetCtrl.text = budget.monthlyBudget.toStringAsFixed(0);
                        setState(() => _editingBudget = true);
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  BudgetProgressBar(spent: spent, budget: budget.monthlyBudget, symbol: '₹', light: true),
                ]),
              ),

              const SizedBox(height: 16),

              // ── Budget edit ────────────────────────
              if (_editingBudget) ...[
                _BudgetEditCard(
                  controller: _budgetCtrl,
                  onSave: (v) async {
                    await context.read<BudgetProvider>().setMonthlyBudget(v);
                    setState(() => _editingBudget = false);
                  },
                  onCancel: () => setState(() => _editingBudget = false),
                ),
                const SizedBox(height: 16),
              ],

              // ── Budget alerts ──────────────────────
              ...budget.alerts.map((a) => _AlertCard(alert: a)),
              if (budget.alerts.isNotEmpty) const SizedBox(height: 16),

              // ── Category limits ────────────────────
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Category Limits',
                    style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ...CategoryModel.defaults.take(8).map((cat) =>
                  _CategoryLimitRow(category: cat, uid: _uid, month: _month)),
            ]),
          );
        },
      ),
    );
  }
}

class _BudgetEditCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onSave;
  final VoidCallback onCancel;
  const _BudgetEditCard({required this.controller, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface2, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(children: [
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppTheme.textPri, fontSize: 24, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(prefixText: '₹  ', hintText: '0'),
        autofocus: true,
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textSec,
              side: const BorderSide(color: AppTheme.border)),
          child: const Text('Cancel'),
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: () {
            final v = double.tryParse(controller.text);
            if (v != null && v > 0) onSave(v);
          },
          child: const Text('Save'),
        )),
      ]),
    ]),
  );
}

class _AlertCard extends StatelessWidget {
  final BudgetAlert alert;
  const _AlertCard({required this.alert});

  static const _colors = {
    'warn75': AppTheme.warning,
    'warn90': AppTheme.danger,
    'over': AppTheme.danger,
    'predictive': AppTheme.accent,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[alert.level] ?? AppTheme.textSec;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(alert.message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _CategoryLimitRow extends StatefulWidget {
  final CategoryModel category;
  final String uid, month;
  const _CategoryLimitRow({required this.category, required this.uid, required this.month});

  @override
  State<_CategoryLimitRow> createState() => _CategoryLimitRowState();
}

class _CategoryLimitRowState extends State<_CategoryLimitRow> {
  final _ctrl = TextEditingController();
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Icon(widget.category.icon, color: AppTheme.textSec, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(widget.category.name,
            style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600))),
        if (_editing) ...[
          SizedBox(width: 80,
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPri, fontSize: 14),
              decoration: const InputDecoration(prefixText: '₹', isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)),
              autofocus: true,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.accentAlt, size: 18),
            onPressed: () async {
              final v = double.tryParse(_ctrl.text);
              if (v != null && v > 0) {
                await context.read<BudgetProvider>().setCategoryLimit(widget.category.name, v);
              }
              setState(() => _editing = false);
            },
          ),
        ] else ...[
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users').doc(widget.uid)
                .collection('budgets').doc(widget.month)
                .collection('categories').doc(widget.category.name).snapshots(),
            builder: (context, snap) {
              final limit = snap.hasData && snap.data!.exists
                  ? ((snap.data!.data() as Map)['limit'] ?? 0).toDouble() : 0.0;
              return Text(limit > 0 ? '₹${limit.toStringAsFixed(0)}' : 'No limit',
                  style: const TextStyle(color: AppTheme.textSec, fontSize: 13));
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.textDim, size: 16),
            onPressed: () => setState(() => _editing = true),
          ),
        ],
      ]),
    );
  }
}
