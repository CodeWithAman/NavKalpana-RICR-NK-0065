import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/analytics_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/health_score_gauge.dart';
import '../screens/add_expense_screen.dart';
import '../screens/ai_insights_screen.dart';
import '../screens/financial_health_screen.dart';
import '../screens/goals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currencySymbolMap = const {
    'USD': r'$', 'EUR': '€', 'INR': '₹', 'GBP': '£', 'JPY': '¥',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAnalytics());
  }

  Future<void> _loadAnalytics() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final d = userSnap.data() ?? {};
    final income = (d['monthlyIncome'] ?? 0).toDouble();
    final budget = (d['monthlyBudget'] ?? 0).toDouble();
    if (!mounted) return;
    context.read<AnalyticsProvider>().loadAnalytics(income: income, budget: budget);
    context.read<BudgetProvider>().setMonthlyBudget(budget);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snap) {
        final d      = snap.data?.data() as Map<String, dynamic>? ?? {};
        final name   = (d['name'] ?? '').toString().split(' ').first;
        final symbol = _currencySymbolMap[d['currency'] ?? 'INR'] ?? '₹';
        final budget = (d['monthlyBudget'] ?? 0).toDouble();
        final income = (d['monthlyIncome'] ?? 0).toDouble();

        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface2,
            onRefresh: _loadAnalytics,
            child: CustomScrollView(
              slivers: [
                // ── App bar ──────────────────────────
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  backgroundColor: AppTheme.bg,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${_capitalize(name)}! 👋',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPri)),
                      Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSec)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppTheme.textSec),
                      onPressed: () {},
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Balance card ───────────────
                      _BalanceCard(uid: user.uid, symbol: symbol, budget: budget, income: income),
                      const SizedBox(height: 16),

                      // ── Quick stats row ────────────
                      _QuickStatsRow(uid: user.uid, symbol: symbol),
                      const SizedBox(height: 20),

                      // ── Budget progress ────────────
                      _SectionHeader(title: 'Monthly Budget', onTap: null),
                      const SizedBox(height: 8),
                      _BudgetSection(uid: user.uid, budget: budget, symbol: symbol),
                      const SizedBox(height: 20),

                      // ── Health score ───────────────
                      _SectionHeader(
                        title: 'Financial Health',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const FinancialHealthScreen())),
                      ),
                      const SizedBox(height: 8),
                      _HealthSection(),
                      const SizedBox(height: 20),

                      // ── AI Insights preview ────────
                      _SectionHeader(
                        title: 'AI Insights',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AiInsightsScreen())),
                      ),
                      const SizedBox(height: 8),
                      _InsightsPreview(),
                      const SizedBox(height: 20),

                      // ── Quick actions ──────────────
                      _QuickActions(),
                      const SizedBox(height: 20),

                      // ── Recent transactions ────────
                      _SectionHeader(title: 'Recent Transactions', onTap: null),
                      const SizedBox(height: 8),
                      _RecentTransactions(uid: user.uid, symbol: symbol),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Balance Card (glass) ──────────────────────────────

class _BalanceCard extends StatelessWidget {
  final String uid, symbol;
  final double budget, income;
  const _BalanceCard({required this.uid, required this.symbol, required this.budget, required this.income});

  @override
  Widget build(BuildContext context) {
    final now     = DateTime.now();
    final monthId = DateFormat('yyyy-MM').format(now);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(uid).collection('analytics').doc(monthId)
          .snapshots(),
      builder: (context, snap) {
        final spent   = snap.hasData && snap.data!.exists
            ? ((snap.data!.data() as Map)['totalSpent'] ?? 0).toDouble()
            : 0.0;
        final savings = income - spent;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Expenses This Month', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Text('$symbol${spent.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Row(children: [
                _stat('Income', '$symbol${income.toStringAsFixed(0)}'),
                const SizedBox(width: 32),
                _stat('Savings', '$symbol${savings.toStringAsFixed(0)}',
                    color: savings >= 0 ? AppTheme.accentAlt : AppTheme.danger),
                const SizedBox(width: 32),
                _stat('Budget', '$symbol${budget.toStringAsFixed(0)}'),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value, {Color color = Colors.white}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
    ],
  );
}

// Quick stats

class _QuickStatsRow extends StatelessWidget {
  final String uid, symbol;
  const _QuickStatsRow({required this.uid, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final now        = DateTime.now();
    final monthId    = DateFormat('yyyy-MM').format(now);
    final todayId    = DateFormat('yyyy-MM-dd').format(now);
    final yestId     = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    return Row(children: [
      Expanded(child: _DailyCard(uid: uid, monthId: monthId, dayId: todayId, label: 'Today', symbol: symbol)),
      const SizedBox(width: 12),
      Expanded(child: _DailyCard(uid: uid, monthId: monthId, dayId: yestId, label: 'Yesterday', symbol: symbol)),
    ]);
  }
}

class _DailyCard extends StatelessWidget {
  final String uid, monthId, dayId, label, symbol;
  const _DailyCard({required this.uid, required this.monthId, required this.dayId, required this.label, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(uid).collection('analytics')
          .doc(monthId).collection('daily').doc(dayId).snapshots(),
      builder: (context, snap) {
        final v = snap.hasData && snap.data!.exists
            ? ((snap.data!.data() as Map)['spent'] ?? 0).toDouble() : 0.0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: glassCard(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
            const SizedBox(height: 6),
            Text('$symbol${v.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.textPri, fontSize: 20, fontWeight: FontWeight.w700)),
          ]),
        );
      },
    );
  }
}

//  Budget section
class _BudgetSection extends StatelessWidget {
  final String uid, symbol;
  final double budget;
  const _BudgetSection({required this.uid, required this.budget, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final monthId = DateFormat('yyyy-MM').format(DateTime.now());
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(uid).collection('analytics').doc(monthId).snapshots(),
      builder: (context, snap) {
        final spent = snap.hasData && snap.data!.exists
            ? ((snap.data!.data() as Map)['totalSpent'] ?? 0).toDouble() : 0.0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: glassCard(),
          child: BudgetProgressBar(spent: spent, budget: budget, symbol: symbol),
        );
      },
    );
  }
}

// ── Health section ────────────────────────────────────

class _HealthSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<AnalyticsProvider>().stats;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: glassCard(),
      child: Row(children: [
        HealthScoreGauge(score: stats.healthScore, size: 80),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(stats.spendingPersonality,
              style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Row(children: [
            RiskBadge(level: stats.riskLevel),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textSec, size: 14),
          ]),
        ])),
      ]),
    );
  }
}

// ── Insights preview ──────────────────────────────────

class _InsightsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final insights = context.watch<AnalyticsProvider>().insights;
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: glassCard(),
        child: const Text('No insights yet. Add more expenses!',
            style: TextStyle(color: AppTheme.textSec)),
      );
    }
    final top = insights.take(2).toList();
    return Column(
      children: top.map((ins) => _InsightChip(insight: ins)).toList(),
    );
  }
}

class _InsightChip extends StatelessWidget {
  final Insight insight;
  const _InsightChip({required this.insight});

  static const _colors = {
    'danger': AppTheme.danger,
    'warning': AppTheme.warning,
    'info': AppTheme.accent,
    'success': AppTheme.accentAlt,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[insight.type] ?? AppTheme.textSec;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: glassCard(),
      child: Row(children: [
        Container(
          width: 4, height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(insight.title,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(insight.body,
              style: const TextStyle(color: AppTheme.textSec, fontSize: 12),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

// ── Quick actions ─────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _ActionBtn(icon: Icons.add_circle, label: 'Add Expense', color: AppTheme.accent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()))),
      const SizedBox(width: 10),
      _ActionBtn(icon: Icons.savings, label: 'Goals', color: AppTheme.accentAlt,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen()))),
      const SizedBox(width: 10),
      _ActionBtn(icon: Icons.smart_toy, label: 'AI Insights', color: AppTheme.warning,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiInsightsScreen()))),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: glassCard(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 11),
              textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

// ── Recent transactions ───────────────────────────────

class _RecentTransactions extends StatelessWidget {
  final String uid, symbol;
  const _RecentTransactions({required this.uid, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end   = start.add(const Duration(days: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(uid).collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: glassCard(),
            child: const Center(
              child: Text('No transactions today', style: TextStyle(color: AppTheme.textSec)),
            ),
          );
        }
        return Column(
          children: snap.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: glassCard(),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surface3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long, color: AppTheme.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['categoryName'] ?? 'Expense',
                      style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
                  if ((d['note'] ?? '').toString().isNotEmpty)
                    Text(d['note'], style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                ])),
                Text('-$symbol${d['amount']}',
                    style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
              ]),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback? onTap;
  const _SectionHeader({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w700, fontSize: 16)),
    const Spacer(),
    if (onTap != null)
      GestureDetector(
        onTap: onTap,
        child: const Text('See all', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
      ),
  ]);
}

class RiskBadge extends StatelessWidget {
  final String level;
  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = {'Low': AppTheme.accentAlt, 'Moderate': AppTheme.warning, 'High': AppTheme.danger};
    final color = colors[level] ?? AppTheme.textSec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text('$level Risk', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
