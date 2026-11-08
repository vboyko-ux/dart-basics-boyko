import 'dart:math' as math;

/// Калькулятор з основними та розширеними операціями.
class Calculator {
  double add(double a, double b) => a + b;
  double subtract(double a, double b) => a - b;
  double multiply(double a, double b) => a * b;

  double divide(double a, double b) {
    if (b == 0) throw ArgumentError('Ділення на нуль');
    return a / b;
  }

  double power(double base, double exponent) =>
      math.pow(base, exponent).toDouble();

  double sqrt(double x) {
    if (x < 0) throw ArgumentError('Корінь з від\'ємного числа');
    return math.sqrt(x);
  }

  /// Виконує операцію за символом: + - * / ^ (для демо консольного калькулятора).
  double calculate(double a, String op, double b) {
    switch (op) {
      case '+':
        return add(a, b);
      case '-':
        return subtract(a, b);
      case '*':
        return multiply(a, b);
      case '/':
        return divide(a, b);
      case '^':
        return power(a, b);
      default:
        throw FormatException('Невідома операція: $op');
    }
  }

  /// Обчислює вираз виду "12 + 3.5" (число, оператор, число).
  double evaluate(String expression) {
    final parts = expression.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) {
      throw FormatException('Очікується формат "a оператор b": $expression');
    }
    final a = double.parse(parts[0]);
    final b = double.parse(parts[2]);
    return calculate(a, parts[1], b);
  }
}

// ---- Вільні функції з завдання 2 ----

/// Сума двох цілих.
int calculateSum(int a, int b) => a + b;

/// Середнє арифметичне; для порожнього списку — 0.
double calculateAverage(List<double> numbers) {
  if (numbers.isEmpty) return 0;
  return numbers.fold<double>(0, (a, b) => a + b) / numbers.length;
}

/// Форматує ім'я: необов'язкове по батькові (named), регістр (named).
String formatName(String firstName, String lastName,
    {String? middleName, bool uppercase = false}) {
  final parts = [
    lastName,
    firstName,
    if (middleName != null && middleName.isNotEmpty) middleName,
  ];
  final result = parts.join(' ');
  return uppercase ? result.toUpperCase() : result;
}

/// n-е число Фібоначчі (ітеративно, щоб не було експоненційної рекурсії).
int fibonacci(int n) {
  if (n < 0) throw ArgumentError('n має бути невід\'ємним');
  var a = 0, b = 1;
  for (var i = 0; i < n; i++) {
    final next = a + b;
    a = b;
    b = next;
  }
  return a;
}

/// Рекурсивний варіант Фібоначчі (для порівняння швидкості у бенчмарку).
int fibonacciRecursive(int n) {
  if (n < 0) throw ArgumentError('n має бути невід\'ємним');
  return n < 2 ? n : fibonacciRecursive(n - 1) + fibonacciRecursive(n - 2);
}

/// Факторіал (рекурсивно). Для n > 20 перевищує int64, тому це помилка.
int factorial(int n) {
  if (n < 0) throw ArgumentError('n має бути невід\'ємним');
  if (n > 20) throw ArgumentError('n > 20 не вміщується в 64-бітний int');
  return n <= 1 ? 1 : n * factorial(n - 1);
}

/// Каррінг: повертає функцію, що множить на [factor] (замикання).
double Function(double) makeMultiplier(double factor) => (x) => x * factor;

/// Лічильник на замиканні: кожен виклик збільшує власний стан.
int Function() makeCounter({int start = 0}) {
  var count = start;
  return () => ++count;
}
