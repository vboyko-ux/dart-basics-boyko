// Завдання 2: функції (звичайні, named/optional параметри, замикання, рекурсія).
import 'package:dart_basics_boyko/dart_basics_boyko.dart';

void main() {
  print('=== Dart Functions Demo ===');
  testBasicFunctions();
  testAdvancedFunctions();
  testFunctionalProgramming();
}

void testBasicFunctions() {
  print('\n--- Звичайні функції ---');
  print('calculateSum(7, 35) = ${calculateSum(7, 35)}');
  print('calculateAverage([80, 90.5, 72]) = '
      '${calculateAverage([80, 90.5, 72]).toStringAsFixed(2)}');
  print('calculateAverage([]) = ${calculateAverage([])}');
}

void testAdvancedFunctions() {
  print('\n--- Optional та named параметри ---');
  print(formatName('Вадим', 'Бойко'));
  print(formatName('Вадим', 'Бойко', middleName: 'Олегович'));
  print(formatName('Вадим', 'Бойко', uppercase: true));
  print(formatName('Вадим', 'Бойко', middleName: 'Олегович', uppercase: true));

  print('\n--- Рекурсія ---');
  print('factorial(5) = ${factorial(5)}, factorial(20) = ${factorial(20)}');
  print('fibonacci(0..10) = ${[for (var i = 0; i <= 10; i++) fibonacci(i)]}');
  print('fibonacci(50) = ${fibonacci(50)}');
  try {
    factorial(25);
  } on ArgumentError catch (e) {
    print('Обробка помилки: factorial(25) -> ${e.message}');
  }
}

void testFunctionalProgramming() {
  print('\n--- Функції як значення: map / where / fold ---');
  final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  print('Квадрати: ${numbers.map((n) => n * n).toList()}');
  print('Парні: ${numbers.where((n) => n.isEven).toList()}');
  print('Сума через fold: ${numbers.fold<int>(0, (a, b) => a + b)}');
  print('Добуток через reduce: ${numbers.take(5).reduce((a, b) => a * b)}');

  // Функція як параметр.
  List<R> transform<T, R>(List<T> items, R Function(T) fn) =>
      [for (final i in items) fn(i)];
  print('transform -> рядки: '
      '${transform<int, String>([1, 2, 3], (n) => "№$n")}');

  print('\n--- Замикання (closures) і scope ---');
  final triple = makeMultiplier(3);
  final tenX = makeMultiplier(10);
  print('triple(7) = ${triple(7)}, tenX(7) = ${tenX(7)}');

  final counterA = makeCounter();
  final counterB = makeCounter(start: 100);
  print('counterA: ${counterA()}, ${counterA()}, ${counterA()}');
  print('counterB: ${counterB()}, ${counterB()} (окремий стан)');

  // Стрілкова нотація та анонімна функція в змінній.
  final squares = [3, 9, 12].map((x) => x * x).toList();
  print('Анонімна функція в map: $squares');

  // Typedef і функція вищого порядку.
  final pipeline = compose<int>([(x) => x + 1, (x) => x * 2, (x) => x - 3]);
  print('compose: ((5 + 1) * 2) - 3 = ${pipeline(5)}');
}

typedef Step<T> = T Function(T);

/// Складає функції в конвеєр (виконуються зліва направо).
Step<T> compose<T>(List<Step<T>> steps) =>
    (input) => steps.fold<T>(input, (acc, step) => step(acc));
