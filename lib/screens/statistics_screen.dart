import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense/expense_bloc.dart';
import '../models/category.dart';
import '../utils/formatters.dart';
import '../widgets/chart_widget.dart';

/// Displays spending analytics: a category pie chart, a daily bar chart,
/// and a ranked breakdown list.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading || state is ExpenseInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
            return Center(child: Text(state.message));
          }

          if (state is ExpenseLoaded) {
            return _StatisticsBody(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.state});

  final ExpenseLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final year = state.selectedYear ?? DateTime.now().year;
    final month = state.selectedMonth ?? DateTime.now().month;

    final dailyData =
        state.expenses.map((e) => (amount: e.amount, date: e.date)).toList();

    // Build category breakdown sorted by total descending.
    final breakdown = state.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // ── Period header ──────────────────────────────────────────────────
        _MonthNavigatorBar(year: year, month: month),
        const SizedBox(height: 16),

        // ── Summary row ────────────────────────────────────────────────────
        Row(
          children: [
            _StatTile(
              label: 'Total Spent',
              value: Formatters.currency(state.monthlyTotal),
              icon: Icons.account_balance_wallet_rounded,
              color: cs.primary,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Transactions',
              value: '${state.expenses.length}',
              icon: Icons.receipt_rounded,
              color: cs.secondary,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Pie chart ──────────────────────────────────────────────────────
        Text('Spending by Category', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryPieChart(
              categoryTotals: state.categoryTotals,
              totalAmount: state.monthlyTotal,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Bar chart ──────────────────────────────────────────────────────
        Text('Daily Spending', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: DailyBarChart(expenses: dailyData, year: year, month: month),
          ),
        ),
        const SizedBox(height: 24),

        // ── Category breakdown list ────────────────────────────────────────
        Text('Category Breakdown', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (breakdown.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No data for this period',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Card(
            color: cs.surfaceContainerLow,
            child: Column(
              children: breakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryId = entry.value.key;
                final amount = entry.value.value;
                final category = Category.byId(categoryId);
                final percentage = state.monthlyTotal > 0
                    ? (amount / state.monthlyTotal) * 100
                    : 0.0;
                final isLast = index == breakdown.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor:
                                      cs.outlineVariant.withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    category.color,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.currency(amount),
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MonthNavigatorBar extends StatelessWidget {
  const _MonthNavigatorBar({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => _navigate(context, -1),
        ),
        Text(
          Formatters.monthYear(DateTime(year, month)),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: isCurrentMonth ? null : () => _navigate(context, 1),
        ),
      ],
    );
  }

  void _navigate(BuildContext context, int delta) {
    var y = year;
    var m = month + delta;
    if (m > 12) {
      m = 1;
      y++;
    } else if (m < 1) {
      m = 12;
      y--;
    }
    context.read<ExpenseBloc>().add(FilterExpensesByMonth(year: y, month: m));
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Card(
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
