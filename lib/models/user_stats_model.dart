// =====================================================
// UserStatsModel – computed financial metrics
// =====================================================

class UserStatsModel {
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyBudget;
  final double savingsRate;       // % of income saved
  final double healthScore;       // 0–100
  final String riskLevel;         // Low / Moderate / High
  final String spendingPersonality;
  final Map<String, double> categoryBreakdown; // category → total spent

  const UserStatsModel({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlyBudget,
    required this.savingsRate,
    required this.healthScore,
    required this.riskLevel,
    required this.spendingPersonality,
    required this.categoryBreakdown,
  });

  double get savings => monthlyIncome - monthlyExpense;
  double get budgetUsedPct =>
      monthlyBudget > 0 ? (monthlyExpense / monthlyBudget * 100).clamp(0, 200) : 0;

  static UserStatsModel empty() => const UserStatsModel(
        monthlyIncome: 0,
        monthlyExpense: 0,
        monthlyBudget: 0,
        savingsRate: 0,
        healthScore: 0,
        riskLevel: 'Low',
        spendingPersonality: 'Unknown',
        categoryBreakdown: {},
      );

  // ── Financial Health Score (0–100) ──────────────────
  // Budget Discipline (30%) + Savings Ratio (25%) +
  // Spending Stability (25%) + Category Diversification (20%)
  static double computeHealthScore({
    required double budgetDiscipline,    // 0–1  (1 = never over budget)
    required double savingsRatio,        // 0–1  (ratio of income saved)
    required double spendingStability,   // 0–1  (low variance)
    required double diversification,     // 0–1  (spread across categories)
  }) {
    return ((budgetDiscipline * 30) +
            (savingsRatio * 25) +
            (spendingStability * 25) +
            (diversification * 20))
        .clamp(0, 100);
  }

  // ── Risk Level ───────────────────────────────────────
  static String computeRisk({
    required double budgetUsedPct,
    required double volatilityScore,  // 0–1
    required int overspendCount,      // number of overspent categories
    required double savingsRate,
  }) {
    int score = 0;
    if (budgetUsedPct > 90) score += 2;
    else if (budgetUsedPct > 75) score += 1;
    if (volatilityScore > 0.6) score += 2;
    else if (volatilityScore > 0.3) score += 1;
    if (overspendCount >= 3) score += 2;
    else if (overspendCount >= 1) score += 1;
    if (savingsRate < 0.05) score += 1;

    if (score >= 5) return 'High';
    if (score >= 2) return 'Moderate';
    return 'Low';
  }

  // ── Spending Personality ─────────────────────────────
  static String detectPersonality({
    required double savingsRate,
    required double budgetAdherence, // 0–1
    required double volatility,      // 0–1
  }) {
    if (savingsRate > 0.25 && budgetAdherence > 0.8) return 'Conservative Planner';
    if (savingsRate > 0.15 && budgetAdherence > 0.6) return 'Structured Budgeter';
    if (savingsRate > 0.10 && volatility < 0.3)      return 'Growth-Oriented Saver';
    if (volatility > 0.6)                             return 'Volatile Spender';
    return 'Impulse Spender';
  }
}
