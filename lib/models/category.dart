import 'package:flutter/material.dart';

/// Represents an expense category with a display icon and colour.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconCodePoint': icon.codePoint,
        'colorValue': color.toARGB32(),
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        icon:
            IconData(map['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
        color: Color(map['colorValue'] as int),
      );

  Category copyWith({String? id, String? name, IconData? icon, Color? color}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';

  // ── Built-in categories ───────────────────────────────────────────────────

  static const List<Category> defaults = [
    Category(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFE53935),
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF1E88E5),
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF8E24AA),
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFF4511E),
    ),
    Category(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFF00ACC1),
    ),
    Category(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFB300),
    ),
    Category(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF43A047),
    ),
    Category(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight_rounded,
      color: Color(0xFF00897B),
    ),
    Category(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF757575),
    ),
  ];

  /// Looks up a default category by [id], falling back to "other".
  static Category byId(String id) =>
      defaults.firstWhere((c) => c.id == id, orElse: () => defaults.last);
}
