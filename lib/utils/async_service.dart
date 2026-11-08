import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/student.dart';

/// Асинхронні сервіси: імітація API, читання/запис JSON, потоки студентів.

/// Імітує запит до API: затримка + JSON з даними студента.
/// Для id "BAD" кидає виняток (щоб показати обробку помилок).
Future<String> fetchStudentData(String studentId,
    {Duration delay = const Duration(milliseconds: 300)}) async {
  await Future<void>.delayed(delay);
  if (studentId == 'BAD') {
    throw StateError('Сервер повернув 404 для $studentId');
  }
  return jsonEncode({
    'id': studentId,
    'firstName': 'Студент',
    'lastName': studentId,
    'birthDate': DateTime(2005, 1, 1).toIso8601String(),
    'grades': {'CS101': 60 + studentId.length * 5},
  });
}

/// Читає список студентів із JSON-файлу (масив об'єктів).
Future<List<Student>> loadStudentsFromFile(String filename) async {
  final file = File(filename);
  if (!await file.exists()) {
    throw FileSystemException('Файл не знайдено', filename);
  }
  final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
  return decoded
      .map((e) => Student.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Записує студентів у JSON-файл (створюючи каталоги за потреби).
Future<void> saveStudentsToFile(List<Student> students, String filename) async {
  final file = File(filename);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file
      .writeAsString(encoder.convert(students.map((s) => s.toJson()).toList()));
}

/// Генерує потік студентів із паузою між елементами (async*).
Stream<Student> studentStream(List<Student> source,
    {Duration interval = const Duration(milliseconds: 100)}) async* {
  for (final student in source) {
    await Future<void>.delayed(interval);
    yield student;
  }
}

/// Завантажує дані кількох студентів паралельно (Future.wait).
Future<List<String>> fetchAllParallel(List<String> ids, {Duration? delay}) =>
    Future.wait(ids.map((id) => fetchStudentData(id,
        delay: delay ?? const Duration(milliseconds: 300))));

/// Те саме, але послідовно — для порівняння продуктивності.
Future<List<String>> fetchAllSequential(List<String> ids,
    {Duration? delay}) async {
  final result = <String>[];
  for (final id in ids) {
    result.add(await fetchStudentData(id,
        delay: delay ?? const Duration(milliseconds: 300)));
  }
  return result;
}
