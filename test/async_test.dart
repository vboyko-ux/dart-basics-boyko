import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_boyko/dart_basics_boyko.dart';
import 'package:test/test.dart';

const fast = Duration(milliseconds: 10);

Student s(String id, double grade) => Student(
      id: id,
      firstName: 'І',
      lastName: 'П$id',
      birthDate: DateTime(2005, 1, 1),
      enrolledCourses: ['CS101'],
      grades: {'CS101': grade},
    );

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('dart_basics_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  group('fetchStudentData', () {
    test('повертає валідний JSON', () async {
      final data = jsonDecode(await fetchStudentData('S1', delay: fast));
      expect(data['id'], 'S1');
    });

    test('id BAD дає StateError', () {
      expect(fetchStudentData('BAD', delay: fast), throwsStateError);
    });

    test('timeout скасовує повільний запит', () {
      expect(
        fetchStudentData('S1', delay: const Duration(seconds: 2))
            .timeout(const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('паралельно проти послідовно', () {
    test('Future.wait швидший за послідовні виклики', () async {
      const ids = ['a', 'b', 'c', 'd'];
      const delay = Duration(milliseconds: 80);
      final sw = Stopwatch()..start();
      await fetchAllSequential(ids, delay: delay);
      final seq = sw.elapsedMilliseconds;
      sw
        ..reset()
        ..start();
      final res = await fetchAllParallel(ids, delay: delay);
      final par = sw.elapsedMilliseconds;
      expect(res.length, 4);
      expect(par, lessThan(seq));
    });
  });

  group('JSON файли', () {
    test('save + load — цілісність даних', () async {
      final path = '${tmp.path}/nested/students.json';
      final original = [s('1', 90), s('2', 55.5)];
      await saveStudentsToFile(original, path);
      final loaded = await loadStudentsFromFile(path);
      expect(loaded.map((e) => e.toJson()), original.map((e) => e.toJson()));
    });

    test('відсутній файл — FileSystemException', () {
      expect(loadStudentsFromFile('${tmp.path}/нема.json'),
          throwsA(isA<FileSystemException>()));
    });

    test('пошкоджений JSON — FormatException', () async {
      final f = File('${tmp.path}/bad.json')..writeAsStringSync('{не json');
      expect(loadStudentsFromFile(f.path), throwsFormatException);
    });
  });

  group('Stream', () {
    test('studentStream віддає всіх у порядку', () async {
      final list = [s('1', 1), s('2', 2), s('3', 3)];
      final ids =
          await studentStream(list, interval: fast).map((e) => e.id).toList();
      expect(ids, ['1', '2', '3']);
    });

    test('конвеєр where + take', () async {
      final list = [s('1', 90), s('2', 50), s('3', 95), s('4', 99)];
      final top = await studentStream(list, interval: fast)
          .where((e) => e.gpa >= 90)
          .take(2)
          .map((e) => e.id)
          .toList();
      expect(top, ['1', '3']);
    });
  });
}
