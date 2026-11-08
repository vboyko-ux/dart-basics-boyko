// Бенчмарки продуктивності (DEL-5). Запуск: dart run bin/benchmark.dart
// Результат дублюється у docs/benchmarks.md.
import 'dart:io';

import 'package:dart_basics_boyko/dart_basics_boyko.dart';

/// Вимірює середній час виклику [fn] у мікросекундах після прогріву.
double measure(void Function() fn, {int runs = 5}) {
  fn(); // прогрів JIT
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    fn();
  }
  sw.stop();
  return sw.elapsedMicroseconds / runs;
}

List<Student> generate(int n) => List.generate(
      n,
      (i) => Student(
        id: 'S$i',
        firstName: 'Ім$i',
        lastName: 'Пр$i',
        birthDate: DateTime(2000 + i % 7, 1 + i % 12, 1 + i % 28),
        enrollmentYear: 2020 + i % 5,
        enrolledCourses: ['CS101', 'CS102'],
        grades: {'CS101': (i * 7 % 61) + 40.0, 'CS102': (i * 13 % 61) + 40.0},
        skills: {'dart', if (i.isEven) 'git'},
      ),
    );

Future<void> main() async {
  final rows = <List<String>>[];
  void add(String name, String size, double us) =>
      rows.add([name, size, us.toStringAsFixed(us < 10 ? 2 : 0)]);

  print('=== Dart performance benchmarks ===');

  // 1. Фібоначчі: ітеративно проти рекурсії.
  add('fibonacci(30) ітеративно', 'n=30',
      measure(() => fibonacci(30), runs: 1000));
  add('fibonacciRecursive(30)', 'n=30',
      measure(() => fibonacciRecursive(30), runs: 3));

  // 2. Обробка колекцій на різних обсягах.
  for (final n in [1000, 10000, 100000]) {
    final students = generate(n);
    add('sortStudentsByGPA', 'n=$n',
        measure(() => DataProcessor.sortStudentsByGPA(students)));
    add('groupStudentsByYear', 'n=$n',
        measure(() => DataProcessor.groupStudentsByYear(students)));
    add('calculateAverageGradesByCourse', 'n=$n',
        measure(() => DataProcessor.calculateAverageGradesByCourse(students)));
    add('getUniqueSkills (Set)', 'n=$n',
        measure(() => DataProcessor.getUniqueSkills(students)));
  }

  // 3. Текст: підрахунок слів.
  final text =
      List.filled(5000, 'Dart це мова для мобільних застосунків').join(' ');
  add('TextAnalyzer.analyze', '${text.length} симв.',
      measure(() => TextAnalyzer.analyze(text)));
  add('DataProcessor.countWords', '${text.length} симв.',
      measure(() => DataProcessor.countWords(text)));

  // 4. List.contains (O(n)) проти Set.contains (O(1)).
  final list = List.generate(20000, (i) => i);
  final set = list.toSet();
  add('List.contains ×1000', 'n=20000', measure(() {
    for (var i = 0; i < 1000; i++) {
      list.contains(19999 - i);
    }
  }));
  add('Set.contains ×1000', 'n=20000', measure(() {
    for (var i = 0; i < 1000; i++) {
      set.contains(19999 - i);
    }
  }));

  // 5. Async: послідовно проти паралельно.
  const ids = ['a', 'b', 'c', 'd', 'e'];
  const delay = Duration(milliseconds: 100);
  var sw = Stopwatch()..start();
  await fetchAllSequential(ids, delay: delay);
  add('5 запитів послідовно (100 мс кожен)', 'async',
      sw.elapsedMicroseconds.toDouble());
  sw = Stopwatch()..start();
  await fetchAllParallel(ids, delay: delay);
  add('5 запитів Future.wait (100 мс кожен)', 'async',
      sw.elapsedMicroseconds.toDouble());

  final w0 = rows.map((r) => r[0].length).reduce((a, b) => a > b ? a : b);
  final out = StringBuffer()
    ..writeln('| Операція | Обсяг | Час, мкс |')
    ..writeln('|---|---|---:|');
  for (final r in rows) {
    out.writeln('| ${r[0]} | ${r[1]} | ${r[2]} |');
    print('${r[0].padRight(w0)}  ${r[1].padRight(14)} ${r[2].padLeft(10)} мкс');
  }
  Directory('docs').createSync(recursive: true);
  File('docs/benchmarks.md').writeAsStringSync(
      '# Бенчмарки\n\nСередній час (мкс) після прогріву; Dart ${Platform.version.split(' ').first}, '
      '${Platform.operatingSystem}. Команда: `dart run bin/benchmark.dart`.\n\n$out');
  print('\nЗбережено: docs/benchmarks.md');
}
