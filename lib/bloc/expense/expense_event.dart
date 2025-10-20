part of 'expense_bloc.dart';

/// Base class for all expense-related events.
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

// ── Read ──────────────────────────────────────────────────────────────────────

/// Load all expenses from the database.
class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

/// Filter expenses to a specific [month] / [year].
class FilterExpensesByMonth extends ExpenseEvent {
  const FilterExpensesByMonth({required this.year, required this.month});

  final int year;
  final int month;

  @override
  List<Object?> get props => [year, month];
}

/// Filter expenses to a specific [categoryId].
class FilterExpensesByCategory extends ExpenseEvent {
  const FilterExpensesByCategory(this.categoryId);

  final String? categoryId; // null == show all

  @override
  List<Object?> get props => [categoryId];
}

// ── Write ─────────────────────────────────────────────────────────────────────

/// Persist a new expense.
class AddExpense extends ExpenseEvent {
  const AddExpense(this.expense);

  final Expense expense;

  @override
  List<Object?> get props => [expense];
}

/// Persist changes to an existing expense.
class UpdateExpense extends ExpenseEvent {
  const UpdateExpense(this.expense);

  final Expense expense;

  @override
  List<Object?> get props => [expense];
}

/// Remove an expense by its [id].
class DeleteExpense extends ExpenseEvent {
  const DeleteExpense(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
