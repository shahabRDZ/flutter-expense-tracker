part of 'expense_bloc.dart';

/// Base class for all expense states.
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

/// Initial / idle state before the first load.
class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

/// Database I/O in progress.
class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

/// Expenses loaded (and optionally filtered) successfully.
class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({
    required this.expenses,
    required this.allExpenses,
    this.selectedCategoryId,
    this.selectedYear,
    this.selectedMonth,
    required this.categoryTotals,
    required this.monthlyTotal,
  });

  /// The filtered subset shown in the list.
  final List<Expense> expenses;

  /// The complete unfiltered list (needed to build the stats charts).
  final List<Expense> allExpenses;

  final String? selectedCategoryId;
  final int? selectedYear;
  final int? selectedMonth;

  /// Map of categoryId → total amount for the active month.
  final Map<String, double> categoryTotals;

  /// Sum of [expenses] amounts.
  final double monthlyTotal;

  @override
  List<Object?> get props => [
    expenses,
    allExpenses,
    selectedCategoryId,
    selectedYear,
    selectedMonth,
    categoryTotals,
    monthlyTotal,
  ];

  ExpenseLoaded copyWith({
    List<Expense>? expenses,
    List<Expense>? allExpenses,
    String? selectedCategoryId,
    int? selectedYear,
    int? selectedMonth,
    Map<String, double>? categoryTotals,
    double? monthlyTotal,
  }) => ExpenseLoaded(
    expenses: expenses ?? this.expenses,
    allExpenses: allExpenses ?? this.allExpenses,
    selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    selectedYear: selectedYear ?? this.selectedYear,
    selectedMonth: selectedMonth ?? this.selectedMonth,
    categoryTotals: categoryTotals ?? this.categoryTotals,
    monthlyTotal: monthlyTotal ?? this.monthlyTotal,
  );
}

/// An error occurred during a database operation.
class ExpenseError extends ExpenseState {
  const ExpenseError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
