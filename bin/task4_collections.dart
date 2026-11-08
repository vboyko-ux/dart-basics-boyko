// Завдання 4: колекції та обробка даних. Вхід: data/students.csv.
// Вихід: output/report.txt, output/report.json, output/students_ranked.csv.
import 'dart:convert';
import 'dart:io';

import 'package:dart_basics_boyko/dart_basics_boyko.dart';

void main() {
  print('=== Dart Collections & Data Processing Demo ===');
  demonstrateLists();
  demonstrateSets();
  demonstrateMaps();
  demonstrateAdvancedOperations();
}

List<Student> _loadStudents() => DataProcessor.parseStudentsCsv(
    File('data/students.csv').readAsStringSync());

void demonstrateLists() {
  print('\n--- Lists: sort, filter, map, where, fold, reduce ---');
  final numbers = [14, 3, 27, 8, 41, 6, 19, 22];
  print('Вихідний: $numbers');
  print(
      'Парні (filterEvenNumbers): ${DataProcessor.filterEvenNumbers(numbers)}');
  print('Відсортований: ${([...numbers]..sort())}');
  print('За спаданням: ${([...numbers]..sort((a, b) => b.compareTo(a)))}');
  print('map (x*2): ${numbers.map((n) => n * 2).toList()}');
  print('where (>15): ${numbers.where((n) => n > 15).toList()}');
  print('fold (сума): ${numbers.fold<int>(0, (a, b) => a + b)}');
  print('reduce (max): ${numbers.reduce((a, b) => a > b ? a : b)}');
  print(
      'any >40: ${numbers.any((n) => n > 40)}, every >2: ${numbers.every((n) => n > 2)}');
  print(
      'take(3): ${numbers.take(3).toList()}, skip(5): ${numbers.skip(5).toList()}');
  print(
      'sublist(2,5): ${numbers.sublist(2, 5)}, indexOf(27): ${numbers.indexOf(27)}');
}

void demonstrateSets() {
  print('\n--- Sets: union, intersection, difference ---');
  final students = _loadStudents();
  final dartFans = students
      .where((s) => s.skills.contains('dart'))
      .map((s) => s.lastName)
      .toSet();
  final gitFans = students
      .where((s) => s.skills.contains('git'))
      .map((s) => s.lastName)
      .toSet();
  print('Знають Dart: $dartFans');
  print('Знають Git:  $gitFans');
  print('union:        ${dartFans.union(gitFans)}');
  print('intersection: ${dartFans.intersection(gitFans)}');
  print('difference:   ${dartFans.difference(gitFans)}');
  print('Усі унікальні навички: '
      '${(DataProcessor.getUniqueSkills(students).toList()..sort())}');
  print('Спільні курси всіх студентів: '
      '${DataProcessor.findCommonCourses(students)}');
}

void demonstrateMaps() {
  print('\n--- Maps: grouping, transformations ---');
  final students = _loadStudents();
  final byYear = DataProcessor.groupStudentsByYear(students);
  byYear.forEach((year, list) => print(
      'Вступ $year: ${list.length} студ. -> ${list.map((s) => s.lastName).join(', ')}'));

  final avg = DataProcessor.calculateAverageGradesByCourse(students);
  print('Середні оцінки за курсами: $avg');

  // Трансформація мапи: курс -> літерна категорія.
  final labels = avg.map((course, grade) => MapEntry(course,
      grade >= 85 ? 'відмінно' : (grade >= 70 ? 'добре' : 'задовільно')));
  print('Категорії: $labels');

  final top =
      (avg.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;
  print('Найвищий середній бал: ${top.key} (${top.value})');

  final wordFreq =
      DataProcessor.countWords(File('data/sample_text.txt').readAsStringSync());
  final topWords = (wordFreq.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)))
      .take(3);
  print(
      'Топ-3 слова тексту: ${topWords.map((e) => '${e.key}=${e.value}').join(', ')}');
}

void demonstrateAdvancedOperations() {
  print('\n--- Комплексна обробка: CSV -> аналіз -> звіти ---');
  final students = _loadStudents();
  print('Прочитано студентів з CSV: ${students.length}');

  // Вкладені колекції: рік -> {курс: середня оцінка}.
  final nested = {
    for (final e in DataProcessor.groupStudentsByYear(students).entries)
      e.key: DataProcessor.calculateAverageGradesByCourse(e.value)
  };
  print('Вкладена мапа (рік -> курс -> середнє):');
  nested.forEach((y, m) => print('  $y: $m'));

  // Власне сортування: спочатку за роком вступу, потім за GPA (спад.).
  final sorted = [...students]..sort((a, b) {
      final byYear = a.enrollmentYear.compareTo(b.enrollmentYear);
      return byYear != 0 ? byYear : b.gpa.compareTo(a.gpa);
    });
  print('Сортування (рік, потім GPA↓): '
      '${sorted.take(4).map((s) => '${s.lastName}/${s.enrollmentYear}/${s.gpa.toStringAsFixed(1)}').join('; ')} …');

  final ranked = DataProcessor.sortStudentsByGPA(students);
  print('Топ-3 за GPA:');
  for (final r in ranked.take(3)) {
    print('  ${r['rank']}. ${r['name']} — ${r['gpa']}');
  }

  // Університет і звіти по курсах.
  final uni = _buildUniversity(students);
  final report = DataProcessor.generateReport(uni);
  final stats = uni.generateStatistics();

  Directory('output').createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  File('output/report.json').writeAsStringSync(encoder
      .convert({'statistics': stats, 'courses': report, 'ranking': ranked}));

  final txt = StringBuffer()
    ..writeln('ЗВІТ: ${uni.name}')
    ..writeln('=' * 60)
    ..writeln(
        'Студентів: ${stats['students']}, середній GPA: ${stats['averageGpa']}, '
        'найкращий: ${stats['bestStudent']}')
    ..writeln()
    ..writeln(
        '${'Курс'.padRight(28)}${'Записано'.padRight(10)}${'Склали'.padRight(8)}Середня');
  for (final r in report) {
    txt.writeln('${(r['course'] as String).padRight(28)}'
        '${'${r['enrolled']}'.padRight(10)}${'${r['passed']}'.padRight(8)}${r['averageGrade']}');
  }
  File('output/report.txt').writeAsStringSync(txt.toString());

  final csv = StringBuffer('rank,id,name,gpa\n');
  for (final r in ranked) {
    csv.writeln('${r['rank']},${r['id']},${r['name']},${r['gpa']}');
  }
  File('output/students_ranked.csv').writeAsStringSync(csv.toString());

  print('\n${txt.toString().trimRight()}');
  print(
      '\nЗбережено: output/report.txt, output/report.json, output/students_ranked.csv');
}

University _buildUniversity(List<Student> students) {
  const names = {
    'CS101': 'Основи програмування',
    'CS102': 'Структури даних',
    'CS201': 'Мобільна розробка',
    'DB201': 'Бази даних',
    'MA101': 'Дискретна математика',
  };
  final uni =
      University(name: 'Інститут сучасних технологій', students: students);
  names.forEach((id, name) => uni.addCourse(Course(
      id: id,
      name: name,
      description: name,
      credits: 5,
      instructor: 'Клименко')));
  return uni;
}
