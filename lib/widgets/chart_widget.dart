import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../utils/formatters.dart';

/// Renders a pie chart broken down by category, with an interactive legend.
class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    super.key,
    required this.categoryTotals,
    required this.totalAmount,
  });

  /// Map of categoryId → total amount for the displayed period.
  final Map<String, double> categoryTotals;
  final double totalAmount;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categoryTotals.isEmpty || widget.totalAmount == 0) {
      return _buildEmpty(theme);
    }

    final sections = _buildSections();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    setState(() => _touchedIndex = null);
                    return;
                  }
                  setState(
                    () => _touchedIndex =
                        response.touchedSection!.touchedSectionIndex,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(theme),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = widget.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryId = entry.value.key;
      final amount = entry.value.value;
      final isTouched = index == _touchedIndex;

      final category = Category.byId(categoryId);
      final percentage = (amount / widget.totalAmount) * 100;

      return PieChartSectionData(
        value: amount,
        color: category.color,
        radius: isTouched ? 70 : 56,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(ThemeData theme) {
    final entries = widget.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries.map((entry) {
        final category = Category.byId(entry.key);
        final percentage = (entry.value / widget.totalAmount) * 100;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${category.name} (${percentage.toStringAsFixed(0)}%)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmpty(ThemeData theme) => SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 64,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No data for this period',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

/// Renders a bar chart showing daily spending for a given month.
class DailyBarChart extends StatelessWidget {
  const DailyBarChart({
    super.key,
    required this.expenses,
    required this.year,
    required this.month,
  });

  final List<({double amount, DateTime date})> expenses;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (expenses.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No data for this period',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final dailyTotals = _buildDailyTotals();
    final maxY = dailyTotals.values.fold<double>(0, (m, v) => v > m ? v : m);

    final bars = dailyTotals.entries
        .map(
          (e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: cs.primary,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        )
        .toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    Formatters.currencyCompact(value),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final day = value.toInt();
                  if (day % 5 != 0 && day != 1) return const SizedBox.shrink();
                  return Text(
                    '$day',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                Formatters.currency(rod.toY),
                theme.textTheme.labelSmall!.copyWith(
                  color: cs.onInverseSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<int, double> _buildDailyTotals() {
    final map = <int, double>{};
    for (final e in expenses) {
      if (e.date.year == year && e.date.month == month) {
        map[e.date.day] = (map[e.date.day] ?? 0) + e.amount;
      }
    }
    return map;
  }
}
