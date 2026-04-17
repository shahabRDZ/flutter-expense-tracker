import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../screens/add_expense_screen.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';

/// Named route identifiers used throughout the app.
abstract class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String statistics = '/statistics';

  /// Central route factory wired into [MaterialApp.onGenerateRoute].
  ///
  /// Using [onGenerateRoute] instead of the static [routes] map lets us pass
  /// typed arguments to screens without relying on dynamic casts scattered
  /// across widget trees.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(settings, const HomeScreen());

      case addExpense:
        return _buildRoute(settings, const AddExpenseScreen());

      case editExpense:
        final expense = settings.arguments as Expense;
        return _buildRoute(settings, AddExpenseScreen(expenseToEdit: expense));

      case statistics:
        return _buildRoute(settings, const StatisticsScreen());

      default:
        // Fallback — show a simple "not found" page rather than crashing.
        return _buildRoute(
          settings,
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page,
  ) => MaterialPageRoute(settings: settings, builder: (_) => page);
}
