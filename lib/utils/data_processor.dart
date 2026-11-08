import '../models/student.dart';
import '../models/university.dart';

/// Обробка колекцій: Lists, Sets, Maps та комплексні звіти.
class DataProcessor {
  // ---------- Lists ----------
  static List<int> filterEvenNumbers(List<int> numbers) =>
      numbers.where((n) => n.isEven).toList();

  /// Частота слів без урахування регістру та розділових знаків.
  static Map<String, int> countWords(String text) {
    final result = <String, int>{};
    for (final m in RegExp(r"[\p{L}\p{N}']+", unicode: true)
        .allMatches(text.toLowerCase())) {
      result.update(m.group(0)!, (v) => v + 1, ifAbsent: () => 1);
    }
    return result;
  }

  /// Студенти за спаданням GPA у вигляді карток (для звітів і JSON).
  static List<Map<String, dynamic>> sortStudentsByGPA(List<Student> students) {
    final sorted = [...students]..sort((a, b) => b.gpa.compareTo(a.gpa));
    return [
      for (var i = 0; i < sorted.length; i++)
        {
          'rank': i + 1,
          'id': sorted[i].id,
          'name': sorted[i].fullName,
          'gpa': double.parse(sorted[i].gpa.toStringAsFixed(2)),
        }
    ];
  }

  // ---------- Sets ----------
  static Set<String> getUniqueSkills(List<Student> students) =>
      students.fold<Set<String>>({}, (acc, s) => acc..addAll(s.skills));

  /// Курси, на які записані ВСІ студенти (перетин множин).
  static Set<String> findCommonCourses(List<Student> students) {
    if (students.isEmpty) return {};
    return students
        .map((s) => s.enrolledCourses.toSet())
        .reduce((a, b) => a.intersection(b));
  }

  // ---------- Maps ----------
  /// Групує студентів за роком вступу (ключ — рядок року).
  static Map<String, List<Student>> groupStudentsByYear(
      List<Student> students) {
    final result = <String, List<Student>>{};
    for (final s in students) {
      result.putIfAbsent('${s.enrollmentYear}', () => []).add(s);
    }
    return result;
  }

  /// Середня оцінка за кожним курсом.
  static Map<String, double> calculateAverageGradesByCourse(
      List<Student> students) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final s in students) {
      s.grades.forEach((course, grade) {
        sums.update(course, (v) => v + grade, ifAbsent: () => grade);
        counts.update(course, (v) => v + 1, ifAbsent: () => 1);
      });
    }
    return {
      for (final e in sums.entries)
        e.key: double.parse((e.value / counts[e.key]!).toStringAsFixed(2))
    };
  }

  // ---------- Advanced ----------
  /// Комплексний звіт по університету: по одному запису на курс.
  static List<Map<String, dynamic>> generateReport(University university) {
    final avgByCourse = calculateAverageGradesByCourse(university.students);
    return [
      for (final course in university.courses)
        () {
          final enrolled = university.getStudentsByCourse(course.id);
          final passed = enrolled
              .where((s) => s.getPassedCourses().contains(course.id))
              .length;
          return {
            'course': course.name,
            'instructor': course.instructor,
            'enrolled': enrolled.length,
            'passed': passed,
            'passRate': enrolled.isEmpty
                ? 0.0
                : double.parse(
                    (passed / enrolled.length * 100).toStringAsFixed(1)),
            'averageGrade': avgByCourse[course.id],
          };
        }()
    ];
  }

  // ---------- CSV ----------
  /// Розбирає CSV: id,firstName,lastName,birthDate,year,skills(;),courses(;),grades(course:grade;).
  /// Перший рядок — заголовок; порожні рядки й коментарі (#) пропускаються.
  static List<Student> parseStudentsCsv(String csv) {
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
    if (lines.length < 2) return [];
    final students = <Student>[];
    for (final line in lines.skip(1)) {
      final f = line.split(',');
      if (f.length < 8) {
        throw FormatException(
            'Некоректний рядок CSV (очікується 8 полів): $line');
      }
      final courses = _splitList(f[6]);
      final grades = <String, double>{};
      for (final pair in _splitList(f[7])) {
        final kv = pair.split(':');
        grades[kv[0]] = double.parse(kv[1]);
      }
      students.add(Student(
        id: f[0].trim(),
        firstName: f[1].trim(),
        lastName: f[2].trim(),
        birthDate: DateTime.parse(f[3].trim()),
        enrollmentYear: int.parse(f[4].trim()),
        skills: _splitList(f[5]).toSet(),
        enrolledCourses: courses,
        grades: grades,
      ));
    }
    return students;
  }

  static List<String> _splitList(String raw) =>
      raw.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}
