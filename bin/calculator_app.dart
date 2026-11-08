// Консольний калькулятор. Запуск:
//   dart run bin/calculator_app.dart              (демо-вирази)
//   dart run bin/calculator_app.dart "12 + 3.5"   (власні вирази)
import 'package:dart_basics_boyko/dart_basics_boyko.dart';

void main(List<String> args) {
  print('=== Консольний калькулятор ===');
  final calc = Calculator();
  final expressions = args.isNotEmpty
      ? args
      : [
          '12 + 3.5',
          '100 - 42',
          '6 * 7',
          '22 / 7',
          '2 ^ 10',
          '5 / 0',
          '3 % 2',
          'abc + 1'
        ];

  for (final expr in expressions) {
    try {
      final result = calc.evaluate(expr);
      print('$expr = ${_format(result)}');
    } on ArgumentError catch (e) {
      print('$expr -> помилка: ${e.message}');
    } on FormatException catch (e) {
      print('$expr -> некоректний ввід: ${e.message}');
    }
  }
  print('sqrt(144) = ${_format(calc.sqrt(144))}');
}

/// Прибирає зайвий ".0" у цілих результатах.
String _format(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(4);
