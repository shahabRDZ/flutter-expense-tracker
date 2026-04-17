import 'package:equatable/equatable.dart';

/// Immutable data model for a single expense entry.
class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
  });

  final String id;
  final String title;

  /// Amount stored in the smallest currency unit (e.g. cents).
  final double amount;

  final String categoryId;
  final DateTime date;
  final String? note;

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as String,
    title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(),
    categoryId: map['categoryId'] as String,
    date: DateTime.parse(map['date'] as String),
    note: map['note'] as String?,
  );

  // ── Mutation helpers ──────────────────────────────────────────────────────

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) => Expense(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    date: date ?? this.date,
    note: note ?? this.note,
  );

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [id, title, amount, categoryId, date, note];

  @override
  String toString() =>
      'Expense(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date)';
}
