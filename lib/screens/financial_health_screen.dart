// FinancialHealthScreen – health score + risk details
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/user_stats_model.dart';
import '../providers/analytics_provider.dart';
import '../widgets/health_score_gauge.dart';
import '../screens/dashboard_screen.dart'; // RiskBadge

class FinancialHealthScreen extends StatelessWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final stats    = provider.stats;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Financial Health')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
  
          _ScoreHero(stats: stats),
          const SizedBox(height: 20),

         
          const _SectionTitle('Score Breakdown'),
          const SizedBox(height: 12),
          _BreakdownGrid(stats: stats),
          const SizedBox(height: 20),

         
          const _SectionTitle('Risk Assessment'),
          const SizedBox(height: 12),
          _RiskCard(stats: stats),
          const SizedBox(height: 20),

          
          const _SectionTitle('Spending Personality'),
          const SizedBox(height: 12),
          _PersonalityCard(stats: stats),
          const SizedBox(height: 20),

          
          const _SectionTitle('Projections'),
          const SizedBox(height: 12),
          _ProjectionCard(
            projected: provider.projectedMonthEnd,
            budget: stats.monthlyBudget,
            momChange: provider.monthOverMonthChange,
          ),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
  );
}

class _ScoreHero extends StatelessWidget {
  final UserStatsModel stats;
  const _ScoreHero({required this.stats});

  String _grade(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        HealthScoreGauge(score: stats.healthScore, size: 100),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${stats.healthScore.toStringAsFixed(0)} / 100',
              style: const TextStyle(color: AppTheme.textPri, fontSize: 28, fontWeight: FontWeight.w800)),
          Text(_grade(stats.healthScore),
              style: TextStyle(
                color: _gradeColor(stats.healthScore), fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RiskBadge(level: stats.riskLevel),
        ])),
      ]),
    );
  }

  Color _gradeColor(double s) {
    if (s >= 80) return AppTheme.accentAlt;
    if (s >= 60) return AppTheme.accent;
    if (s >= 40) return AppTheme.warning;
    return AppTheme.danger;
  }
}

class _BreakdownGrid extends StatelessWidget {
  final UserStatsModel stats;
  const _BreakdownGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final budgetPct   = stats.monthlyBudget > 0
        ? ((1 - stats.monthlyExpense / stats.monthlyBudget).clamp(0, 1) * 100).toDouble()
        : 0.0;
    final savingsPct  = (stats.savingsRate * 100).clamp(0, 100).toDouble();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(label: 'Budget Discipline', value: budgetPct, weight: 30, color: AppTheme.accent),
        _MetricCard(label: 'Savings Ratio', value: savingsPct, weight: 25, color: AppTheme.accentAlt),
        _MetricCard(label: 'Spending Stability', value: 70, weight: 25, color: AppTheme.warning),
        _MetricCard(label: 'Diversification',
            value: (stats.categoryBreakdown.length / 5 * 100).clamp(0, 100).toDouble(),
            weight: 20, color: AppTheme.danger),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label; final double value, weight; final Color color;
  const _MetricCard({required this.label, required this.value, required this.weight, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
      const SizedBox(height: 6),
      Text('${value.toStringAsFixed(0)}%',
          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (value / 100).clamp(0, 1),
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
        ),
      ),
      const SizedBox(height: 4),
      Text('Weight: ${weight.toInt()}%',
          style: const TextStyle(color: AppTheme.textDim, fontSize: 10)),
    ]),
  );
}

class _RiskCard extends StatelessWidget {
  final UserStatsModel stats;
  const _RiskCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = {'Low': AppTheme.accentAlt, 'Moderate': AppTheme.warning, 'High': AppTheme.danger};
    final color  = colors[stats.riskLevel] ?? AppTheme.textSec;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.shield, color: color, size: 22),
          const SizedBox(width: 10),
          Text(stats.riskLevel, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
          const Text(' Risk', style: TextStyle(color: AppTheme.textSec, fontSize: 18)),
        ]),
        const SizedBox(height: 12),
        _riskRow('Budget Utilisation', '${stats.budgetUsedPct.toStringAsFixed(0)}%',
            stats.budgetUsedPct > 90 ? AppTheme.danger : AppTheme.accentAlt),
        _riskRow('Savings Rate', '${(stats.savingsRate * 100).toStringAsFixed(0)}%',
            stats.savingsRate < 0.1 ? AppTheme.danger : AppTheme.accentAlt),
        _riskRow('Monthly Expense', '₹${stats.monthlyExpense.toStringAsFixed(0)}', AppTheme.textPri),
      ]),
    );
  }

  Widget _riskRow(String label, String value, Color vColor) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(children: [
      Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
      const Spacer(),
      Text(value, style: TextStyle(color: vColor, fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
  );
}

class _PersonalityCard extends StatelessWidget {
  final UserStatsModel stats;
  const _PersonalityCard({required this.stats});

  static const _descriptions = {
    'Conservative Planner': 'You carefully plan your finances, maintain low risk, and consistently save above 25%. Excellent financial habits!',
    'Structured Budgeter': 'You follow a structured approach to budgeting with good discipline. Keep building your savings.',
    'Growth-Oriented Saver': 'You are focused on growing your wealth with moderate savings and low volatility in spending.',
    'Volatile Spender': 'Your spending pattern shows high variability. Consider setting stricter category budgets.',
    'Impulse Spender': 'Your spending may be driven by impulses. Try the 24-hour rule before making non-essential purchases.',
  };

  @override
  Widget build(BuildContext context) {
    final desc = _descriptions[stats.spendingPersonality] ?? 'Keep tracking your expenses to get a more accurate profile.';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.psychology, color: AppTheme.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(stats.spendingPersonality,
              style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16))),
        ]),
        const SizedBox(height: 10),
        Text(desc, style: const TextStyle(color: AppTheme.textSec, height: 1.5)),
      ]),
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  final double projected, budget, momChange;
  const _ProjectionCard({required this.projected, required this.budget, required this.momChange});

  @override
  Widget build(BuildContext context) {
    final overBudget = budget > 0 && projected > budget;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface2, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Projected Month-End Spend',
              style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
          if (overBudget)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('Over Budget', style: TextStyle(color: AppTheme.danger, fontSize: 11)),
            ),
        ]),
        const SizedBox(height: 6),
        Text('₹${projected.toStringAsFixed(0)}',
            style: TextStyle(
              color: overBudget ? AppTheme.danger : AppTheme.textPri,
              fontSize: 28, fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 12),
        Row(children: [
          const Text('MoM Change:', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
          const SizedBox(width: 8),
          Text('${momChange >= 0 ? '+' : ''}${momChange.toStringAsFixed(1)}%',
              style: TextStyle(
                color: momChange > 0 ? AppTheme.danger : AppTheme.accentAlt,
                fontWeight: FontWeight.w700, fontSize: 13,
              )),
        ]),
      ]),
    );
  }
}
