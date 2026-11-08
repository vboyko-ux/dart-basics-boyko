// Завдання 5: асинхронне програмування — Future, Stream, файловий ввід/вивід.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_boyko/dart_basics_boyko.dart';

void main() async {
  print('=== Dart Async Programming Demo ===');
  await demonstrateFutures();
  await demonstrateStreams();
  await demonstrateFileOperations();
}

Future<void> demonstrateFutures() async {
  print('\n--- Futures: await, Future.wait, помилки, timeout ---');
  final sw = Stopwatch()..start();
  final one =
      jsonDecode(await fetchStudentData('S001')) as Map<String, dynamic>;
  print('Один запит (${sw.elapsedMilliseconds} мс): ${one['lastName']}');

  final ids = ['S001', 'S002', 'S003', 'S004', 'S005'];
  sw
    ..reset()
    ..start();
  await fetchAllSequential(ids);
  final seq = sw.elapsedMilliseconds;
  sw
    ..reset()
    ..start();
  await fetchAllParallel(ids);
  final par = sw.elapsedMilliseconds;
  print('5 запитів послідовно: $seq мс, паралельно (Future.wait): $par мс, '
      'прискорення ×${(seq / par).toStringAsFixed(1)}');

  // Обробка помилок: try/catch і catchError.
  try {
    await fetchStudentData('BAD');
  } on StateError catch (e) {
    print('try/catch: ${e.message}');
  }
  final fallback = await fetchStudentData('BAD')
      .catchError((Object e) => jsonEncode({'error': e.toString()}));
  print('catchError -> $fallback');

  // Timeout: повільний запит відхиляється.
  try {
    await fetchStudentData('S777', delay: const Duration(seconds: 2))
        .timeout(const Duration(milliseconds: 500));
  } on TimeoutException {
    print('timeout: запит перевищив 500 мс і скасований');
  }

  // Future.wait з eagerError: перший збій перериває очікування.
  try {
    await Future.wait([fetchStudentData('S001'), fetchStudentData('BAD')],
        eagerError: true);
  } on StateError catch (e) {
    print('Future.wait(eagerError): ${e.message}');
  }
}

Future<void> demonstrateStreams() async {
  print('\n--- Streams: listen, transform, await for ---');
  final students = DataProcessor.parseStudentsCsv(
      await File('data/students.csv').readAsString());

  // listen + підписка.
  final completer = Completer<void>();
  var shown = 0;
  studentStream(students.take(4).toList(),
          interval: const Duration(milliseconds: 50))
      .listen(
    (s) => print('  отримано: ${s.fullName} (GPA ${s.gpa.toStringAsFixed(1)})'),
    onDone: () {
      print('  потік завершено');
      completer.complete();
    },
    onError: (Object e) => print('  помилка потоку: $e'),
  );
  await completer.future;

  // Трансформації: where + map + take.
  final topNames =
      await studentStream(students, interval: const Duration(milliseconds: 20))
          .where((s) => s.gpa >= 85)
          .map((s) => s.lastName)
          .take(3)
          .toList();
  print('Перші 3 студенти з GPA ≥ 85 (stream pipeline): $topNames');

  // await for: послідовна обробка з агрегуванням.
  var sum = 0.0;
  await for (final s
      in studentStream(students, interval: const Duration(milliseconds: 10))) {
    sum += s.gpa;
    shown++;
  }
  print(
      'await for: опрацьовано $shown студентів, середній GPA ${(sum / shown).toStringAsFixed(2)}');

  // StreamController: власне джерело подій.
  final controller = StreamController<int>();
  final collected = controller.stream.map((n) => n * n).toList();
  for (var i = 1; i <= 5; i++) {
    controller.add(i);
  }
  await controller.close();
  print('StreamController (квадрати 1..5): ${await collected}');
}

Future<void> demonstrateFileOperations() async {
  print('\n--- File I/O: Read -> Process -> Write ---');
  final sw = Stopwatch()..start();

  // Read: CSV -> модель.
  final students = DataProcessor.parseStudentsCsv(
      await File('data/students.csv').readAsString());
  print('Read: прочитано ${students.length} студентів з CSV '
      '(${sw.elapsedMilliseconds} мс)');

  // Write: збереження у JSON.
  sw.reset();
  await saveStudentsToFile(students, 'output/students.json');
  final size = await File('output/students.json').length();
  print(
      'Write: output/students.json, $size байт (${sw.elapsedMilliseconds} мс)');

  // Read назад + перевірка цілісності.
  sw.reset();
  final loaded = await loadStudentsFromFile('output/students.json');
  final same = loaded.length == students.length &&
      loaded.first.toJson().toString() == students.first.toJson().toString();
  print(
      'Read JSON: ${loaded.length} студентів, цілісність: ${same ? 'OK' : 'ПОМИЛКА'} '
      '(${sw.elapsedMilliseconds} мс)');

  // Process: асинхронна обробка + запис результату.
  final ranked = DataProcessor.sortStudentsByGPA(loaded);
  await File('output/async_ranking.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(ranked));
  print(
      'Process+Write: output/async_ranking.json, лідер — ${ranked.first['name']}');

  // Обробка помилок файлової системи.
  try {
    await loadStudentsFromFile('output/missing.json');
  } on FileSystemException catch (e) {
    print('Помилка I/O оброблена: ${e.message} (${e.path})');
  }
  try {
    await File('output/broken.json').writeAsString('{не json');
    await loadStudentsFromFile('output/broken.json');
  } on FormatException catch (e) {
    print('Помилка формату оброблена: ${e.runtimeType}');
  } finally {
    final broken = File('output/broken.json');
    if (await broken.exists()) await broken.delete();
  }
}
