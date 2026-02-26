// GoalsScreen – goal management + auto allocation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_progress_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Financial Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.accent),
            onPressed: () => _showAddGoalSheet(context),
          ),
        ],
      ),
      body: StreamBuilder<List<GoalModel>>(
        stream: context.read<GoalProvider>().streamGoals(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }
          final goals = snap.data!;
          if (goals.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.savings, color: AppTheme.textDim, size: 64),
              const SizedBox(height: 16),
              const Text('No goals yet', style: TextStyle(color: AppTheme.textSec, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Tap + to create your first financial goal',
                  style: TextStyle(color: AppTheme.textDim)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Goal'),
                onPressed: () => _showAddGoalSheet(context),
              ),
            ]));
          }

          final totalTarget = goals.fold(0.0, (s, g) => s + g.targetAmount);
          final totalSaved  = goals.fold(0.0, (s, g) => s + g.savedAmount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Summary card ───────────────────────
              _GoalSummaryCard(totalTarget: totalTarget, totalSaved: totalSaved),
              const SizedBox(height: 20),

    
              ...goals.map((g) => GoalProgressCard(
                goal: g,
                onAddAmount: () => _showAddAmountSheet(context, g),
                onDelete: () => context.read<GoalProvider>().deleteGoal(g.id),
              )),

              
              const SizedBox(height: 8),
              _AllocationCard(goals: goals),
            ]),
          );
        },
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddGoalSheet(),
    );
  }

  void _showAddAmountSheet(BuildContext context, GoalModel goal) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20, right: 20, top: 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add to "${goal.title}"',
              style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPri, fontSize: 24, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(prefixText: '₹  ', hintText: '0'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final v = double.tryParse(ctrl.text);
                if (v != null && v > 0) {
                  await context.read<GoalProvider>().addToGoal(goal.id, v);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            )),
        ]),
      ),
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  final double totalTarget, totalSaved;
  const _GoalSummaryCard({required this.totalTarget, required this.totalSaved});

  @override
  Widget build(BuildContext context) {
    final pct = totalTarget > 0 ? totalSaved / totalTarget : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentAlt, Color(0xFF059669)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overall Goal Progress', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        Text('₹${totalSaved.toStringAsFixed(0)} / ₹${totalTarget.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0, 1),
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text('${(pct * 100).toStringAsFixed(0)}% of all goals funded',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  final List<GoalModel> goals;
  const _AllocationCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
          SizedBox(width: 8),
          Text('Suggested Monthly Allocation', style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        ...goals.where((g) => g.progress < 1).map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(child: Text(g.title, style: const TextStyle(color: AppTheme.textSec, fontSize: 13))),
            Text('₹${g.requiredMonthlySaving.toStringAsFixed(0)}/mo',
                style: const TextStyle(color: AppTheme.accentAlt, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        )),
      ]),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  GoalType _type    = GoalType.emergencyFund;
  DateTime _deadline= DateTime.now().add(const Duration(days: 365));
  int _priority     = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('New Goal', style: TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 16),

          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: AppTheme.textPri),
            decoration: const InputDecoration(hintText: 'Goal name'),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textPri),
            decoration: const InputDecoration(hintText: 'Target amount', prefixText: '₹  '),
          ),
          const SizedBox(height: 12),

          // Type picker
          DropdownButtonFormField<GoalType>(
            value: _type,
            dropdownColor: AppTheme.surface2,
            style: const TextStyle(color: AppTheme.textPri),
            decoration: const InputDecoration(hintText: 'Goal type'),
            items: GoalType.values.map((t) => DropdownMenuItem(
              value: t,
              child: Text(_goalTypeName(t), style: const TextStyle(color: AppTheme.textPri)),
            )).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),

          // Deadline
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context, initialDate: _deadline,
                firstDate: DateTime.now(), lastDate: DateTime(2035),
              );
              if (d != null) setState(() => _deadline = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: AppTheme.surface3, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border)),
              child: Row(children: [
                const Icon(Icons.event, color: AppTheme.textSec, size: 18),
                const SizedBox(width: 10),
                Text('Deadline: ${DateFormat('dd MMM yyyy').format(_deadline)}',
                    style: const TextStyle(color: AppTheme.textPri)),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Priority
          Row(children: [
            const Text('Priority:', style: TextStyle(color: AppTheme.textSec)),
            const SizedBox(width: 12),
            ...List.generate(3, (i) => GestureDetector(
              onTap: () => setState(() => _priority = i + 1),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _priority == i + 1 ? AppTheme.accent : AppTheme.surface3,
                  shape: BoxShape.circle,
                  border: Border.all(color: _priority == i + 1 ? AppTheme.accent : AppTheme.border),
                ),
                child: Center(child: Text('${i+1}', style: TextStyle(
                    color: _priority == i + 1 ? Colors.white : AppTheme.textSec,
                    fontWeight: FontWeight.w700))),
              ),
            )),
          ]),
          const SizedBox(height: 20),

          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final title = _titleCtrl.text.trim();
                final amount= double.tryParse(_amountCtrl.text);
                if (title.isEmpty || amount == null || amount <= 0) return;
                final goal = GoalModel(
                  id: '', title: title, type: _type,
                  targetAmount: amount, savedAmount: 0,
                  deadline: _deadline, priority: _priority,
                );
                await context.read<GoalProvider>().addGoal(goal);
                Navigator.pop(context);
              },
              child: const Text('Create Goal'),
            )),
        ]),
      ),
    );
  }

  String _goalTypeName(GoalType t) {
    const names = {
      GoalType.emergencyFund: 'Emergency Fund',
      GoalType.vacation: 'Vacation',
      GoalType.gadget: 'Gadget Purchase',
      GoalType.education: 'Education Fee',
      GoalType.debtRepayment: 'Debt Repayment',
      GoalType.custom: 'Custom',
    };
    return names[t] ?? t.name;
  }
}
