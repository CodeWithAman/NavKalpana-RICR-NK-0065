import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/analytics_provider.dart';
import '../widgets/ai_recommendation_card.dart';
import '../screens/dashboard_screen.dart'; // RiskBadge

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final stats     = analytics.stats;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('AI Insights'),
        actions: [
          if (analytics.loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
            ),
        ],
      ),
      body: analytics.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── AI header banner ─────────────────
                _AiBanner(personality: stats.spendingPersonality, score: stats.healthScore),
                const SizedBox(height: 20),

                // ── Insights list ────────────────────
                if (analytics.insights.isEmpty)
                  _EmptyInsights()
                else ...[
                  _sectionTitle('Smart Recommendations'),
                  const SizedBox(height: 10),
                  ...analytics.insights.map((ins) => AiRecommendationCard(insight: ins)),
                ],

                const SizedBox(height: 20),

                // ── Behavioral intelligence ──────────
                _sectionTitle('Behavioral Intelligence'),
                const SizedBox(height: 10),
                _BehavioralCards(stats: stats),
                const SizedBox(height: 20),

                // ── Risk summary ─────────────────────
                _sectionTitle('Risk Summary'),
                const SizedBox(height: 10),
                _RiskSummaryCard(stats: stats),
                const SizedBox(height: 20),

                // ── Personality ──────────────────────
                _sectionTitle('Spending Personality'),
                const SizedBox(height: 10),
                _PersonalityBadge(personality: stats.spendingPersonality),
              ]),
            ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16));
}

class _AiBanner extends StatelessWidget {
  final String personality; final double score;
  const _AiBanner({required this.personality, required this.score});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4C1D95)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('LEDGER AI', style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(personality, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 2),
        Text('Health Score: ${score.toStringAsFixed(0)}/100',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ])),
    ]),
  );
}

class _EmptyInsights extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: const Column(children: [
      Icon(Icons.lightbulb_outline, color: AppTheme.textDim, size: 40),
      SizedBox(height: 12),
      Text('Add more expenses to get personalized insights.',
          style: TextStyle(color: AppTheme.textSec), textAlign: TextAlign.center),
    ]),
  );
}

class _BehavioralCards extends StatelessWidget {
  final dynamic stats;
  const _BehavioralCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _BehaviorRow(
        icon: Icons.weekend,
        label: 'Weekend Spending Pattern',
        value: 'Analysing...',
        description: 'Weekend vs weekday patterns calculated from your recent transactions.',
      ),
      const SizedBox(height: 8),
      _BehaviorRow(
        icon: Icons.show_chart,
        label: 'Mid-Month Activity',
        value: 'Variable',
        description: 'Watch for mid-month spending spikes which may strain your budget end-of-month.',
      ),
      const SizedBox(height: 8),
      _BehaviorRow(
        icon: Icons.repeat,
        label: 'Subscription Detection',
        value: 'Active',
        description: 'Recurring patterns are detected from your transaction history.',
      ),
    ]);
  }
}

class _BehaviorRow extends StatelessWidget {
  final IconData icon; final String label, value, description;
  const _BehaviorRow({required this.icon, required this.label, required this.value, required this.description});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.accent, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label,
              style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600, fontSize: 13))),
          Text(value, style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: AppTheme.textSec, fontSize: 12, height: 1.4)),
      ])),
    ]),
  );
}

class _RiskSummaryCard extends StatelessWidget {
  final dynamic stats;
  const _RiskSummaryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = {'Low': AppTheme.accentAlt, 'Moderate': AppTheme.warning, 'High': AppTheme.danger};
    final color  = colors[stats.riskLevel] ?? AppTheme.textSec;
    final budgetPct = stats.budgetUsedPct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.security, color: color),
          const SizedBox(width: 10),
          Text('Risk Level: ${stats.riskLevel}',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        _riskRow('Budget Utilisation', '${budgetPct.toStringAsFixed(0)}%', budgetPct > 75 ? AppTheme.danger : AppTheme.accentAlt),
        _riskRow('Savings Rate', '${(stats.savingsRate * 100).toStringAsFixed(0)}%',
            stats.savingsRate < 0.1 ? AppTheme.danger : AppTheme.accentAlt),
        _riskRow('Risk Category', stats.riskLevel, color),
      ]),
    );
  }

  Widget _riskRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(l, style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
      const Spacer(),
      Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
  );
}

class _PersonalityBadge extends StatelessWidget {
  final String personality;
  const _PersonalityBadge({required this.personality});

  static const _emojis = {
    'Conservative Planner': '🧮',
    'Structured Budgeter': '📊',
    'Growth-Oriented Saver': '📈',
    'Volatile Spender': '🎢',
    'Impulse Spender': '🛒',
  };

  static const _colors = {
    'Conservative Planner': AppTheme.accentAlt,
    'Structured Budgeter': AppTheme.accent,
    'Growth-Oriented Saver': Color(0xFF10B981),
    'Volatile Spender': AppTheme.danger,
    'Impulse Spender': AppTheme.warning,
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[personality] ?? '💡';
    final color = _colors[personality] ?? AppTheme.accent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your Profile', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
          const SizedBox(height: 4),
          Text(personality, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
        ])),
      ]),
    );
  }
}
