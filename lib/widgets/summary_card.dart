import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Displays a top-level monthly summary: total spent, largest category,
/// and number of transactions.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalAmount,
    required this.transactionCount,
    required this.topCategory,
    required this.month,
    required this.year,
  });

  final double totalAmount;
  final int transactionCount;
  final String? topCategory;
  final int month;
  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.monthYear(DateTime(year, month)),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onPrimary.withOpacity(0.85),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Big total
          Text(
            Formatters.currency(totalAmount),
            style: theme.textTheme.displaySmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Total spent this month',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onPrimary.withOpacity(0.75),
            ),
          ),

          if (topCategory != null) ...[
            const SizedBox(height: 12),
            Divider(color: cs.onPrimary.withOpacity(0.20), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: cs.onPrimary.withOpacity(0.75),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Top category: $topCategory',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimary.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
