import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/database_helper.dart';
import '../../models/expense.dart';

part 'expense_event.dart';
part 'expense_state.dart';

/// Manages all expense-related business logic and database interactions.
///
/// Emits [ExpenseLoaded] after every successful operation so the UI always
/// reflects the latest persisted state.
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc(this._db) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<FilterExpensesByMonth>(_onFilterByMonth);
    on<FilterExpensesByCategory>(_onFilterByCategory);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  final DatabaseHelper _db;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Build a fully-populated [ExpenseLoaded] state from fresh DB reads.
  Future<ExpenseLoaded> _buildLoadedState({
    String? categoryId,
    int? year,
    int? month,
  }) async {
    final all = await _db.getAllExpenses();

    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    // Apply optional category filter on top of the month filter.
    final filtered = all.where((e) {
      final matchesMonth =
          e.date.year == targetYear && e.date.month == targetMonth;
      final matchesCategory = categoryId == null || e.categoryId == categoryId;
      return matchesMonth && matchesCategory;
    }).toList();

    final totals = await _db.getCategoryTotalsForMonth(targetYear, targetMonth);
    final monthlyTotal = filtered.fold<double>(0, (sum, e) => sum + e.amount);

    return ExpenseLoaded(
      expenses: filtered,
      allExpenses: all,
      selectedCategoryId: categoryId,
      selectedYear: targetYear,
      selectedMonth: targetMonth,
      categoryTotals: totals,
      monthlyTotal: monthlyTotal,
    );
  }

  // ── Event handlers ────────────────────────────────────────────────────────

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    try {
      emit(await _buildLoadedState());
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  Future<void> _onFilterByMonth(
    FilterExpensesByMonth event,
    Emitter<ExpenseState> emit,
  ) async {
    final current = state;
    final categoryId =
        current is ExpenseLoaded ? current.selectedCategoryId : null;

    emit(const ExpenseLoading());
    try {
      emit(
        await _buildLoadedState(
          categoryId: categoryId,
          year: event.year,
          month: event.month,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to filter expenses: $e'));
    }
  }

  Future<void> _onFilterByCategory(
    FilterExpensesByCategory event,
    Emitter<ExpenseState> emit,
  ) async {
    final current = state;
    int? year, month;
    if (current is ExpenseLoaded) {
      year = current.selectedYear;
      month = current.selectedMonth;
    }

    emit(const ExpenseLoading());
    try {
      emit(
        await _buildLoadedState(
          categoryId: event.categoryId,
          year: year,
          month: month,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to filter expenses: $e'));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _db.insertExpense(event.expense);
      final current = state;
      final year = current is ExpenseLoaded ? current.selectedYear : null;
      final month = current is ExpenseLoaded ? current.selectedMonth : null;
      final categoryId =
          current is ExpenseLoaded ? current.selectedCategoryId : null;
      emit(
        await _buildLoadedState(
          categoryId: categoryId,
          year: year,
          month: month,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to add expense: $e'));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _db.updateExpense(event.expense);
      final current = state;
      final year = current is ExpenseLoaded ? current.selectedYear : null;
      final month = current is ExpenseLoaded ? current.selectedMonth : null;
      final categoryId =
          current is ExpenseLoaded ? current.selectedCategoryId : null;
      emit(
        await _buildLoadedState(
          categoryId: categoryId,
          year: year,
          month: month,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _db.deleteExpense(event.id);
      final current = state;
      final year = current is ExpenseLoaded ? current.selectedYear : null;
      final month = current is ExpenseLoaded ? current.selectedMonth : null;
      final categoryId =
          current is ExpenseLoaded ? current.selectedCategoryId : null;
      emit(
        await _buildLoadedState(
          categoryId: categoryId,
          year: year,
          month: month,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }
}
