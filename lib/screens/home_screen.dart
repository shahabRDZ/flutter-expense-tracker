import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense/expense_bloc.dart';
import '../config/routes.dart';
import '../models/category.dart';
import '../utils/formatters.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';

/// The app's main screen.
///
/// Shows a monthly summary, a category filter row, and the paginated expense
/// list. Navigation to Add Expense, Edit Expense, and Statistics is provided
/// from this screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addExpense),
        tooltip: 'Add expense',
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
            return _buildError(context, state.message);
          }

          if (state is ExpenseLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) =>
      AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistics',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.statistics),
          ),
          const SizedBox(width: 4),
        ],
      );

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, ExpenseLoaded state) {
    final topCategoryId = state.categoryTotals.isEmpty
        ? null
        : (state.categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;

    final topCategoryName = topCategoryId != null
        ? Category.byId(topCategoryId).name
        : null;

    return CustomScrollView(
      slivers: [
        // Summary card
        SliverToBoxAdapter(
          child: SummaryCard(
            totalAmount: state.monthlyTotal,
            transactionCount: state.expenses.length,
            topCategory: topCategoryName,
            month: state.selectedMonth ?? DateTime.now().month,
            year: state.selectedYear ?? DateTime.now().year,
          ),
        ),

        // Month navigator
        SliverToBoxAdapter(
          child: _MonthNavigator(
            year: state.selectedYear ?? DateTime.now().year,
            month: state.selectedMonth ?? DateTime.now().month,
          ),
        ),

        // Category filter chips
        SliverToBoxAdapter(
          child: _CategoryFilterRow(
            selectedCategoryId: state.selectedCategoryId,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Expense list
        if (state.expenses.isEmpty)
          SliverFillRemaining(child: _buildEmpty(context))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => ExpenseCard(expense: state.expenses[index]),
              childCount: state.expenses.length,
            ),
          ),

        // Bottom padding so the FAB doesn't overlap last item.
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first expense',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () =>
                  context.read<ExpenseBloc>().add(const LoadExpenses()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Arrow-based month navigator that dispatches [FilterExpensesByMonth].
class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _navigate(context, -1),
          ),
          const SizedBox(width: 4),
          Text(
            Formatters.monthYear(DateTime(year, month)),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: isCurrentMonth ? null : () => _navigate(context, 1),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int delta) {
    var newYear = year;
    var newMonth = month + delta;
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }
    context.read<ExpenseBloc>().add(
      FilterExpensesByMonth(year: newYear, month: newMonth),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Horizontal scrollable row of category filter chips.
class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({this.selectedCategoryId});

  final String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categories = Category.defaults;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All" chip
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: selectedCategoryId == null,
              onSelected: (_) => context.read<ExpenseBloc>().add(
                const FilterExpensesByCategory(null),
              ),
            );
          }
          final category = categories[index - 1];
          return FilterChip(
            avatar: Icon(category.icon, size: 16, color: category.color),
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => context.read<ExpenseBloc>().add(
              FilterExpensesByCategory(category.id),
            ),
          );
        },
      ),
    );
  }
}
