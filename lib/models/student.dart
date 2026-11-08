import 'person.dart';

/// Студент: успадковує [Person], додає курси, оцінки та навички.
class Student extends Person {
  /// Мінімальна оцінка, з якою курс вважається складеним.
  static const double passingGrade = 60;

  /// Рік вступу (потрібен для групування за курсами навчання).
  final int enrollmentYear;
  final List<String> enrolledCourses;
  final Map<String, double> grades;
  final Set<String> skills;

  Student({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    this.enrollmentYear = 2023,
    List<String>? enrolledCourses,
    Map<String, double>? grades,
    Set<String>? skills,
  })  : enrolledCourses = enrolledCourses ?? [],
        grades = grades ?? {},
        skills = skills ?? {};

  @override
  String get role => 'Student';

  /// Середній бал за 100-бальною шкалою (0, якщо оцінок ще немає).
  double get gpa {
    if (grades.isEmpty) return 0;
    final sum = grades.values.fold<double>(0, (a, b) => a + b);
    return sum / grades.length;
  }

  /// Записує студента на курс. Повторний запис ігнорується.
  void enrollInCourse(String courseId) {
    if (!enrolledCourses.contains(courseId)) {
      enrolledCourses.add(courseId);
    }
  }

  /// Додає оцінку (0–100) за курс, на який студент записаний.
  void addGrade(String courseId, double grade) {
    if (grade < 0 || grade > 100) {
      throw RangeError.range(grade.round(), 0, 100, 'grade');
    }
    if (!enrolledCourses.contains(courseId)) {
      throw StateError('Студент $id не записаний на курс $courseId');
    }
    grades[courseId] = grade;
  }

  /// Курси, складені з оцінкою не нижче [passingGrade].
  List<String> getPassedCourses() => grades.entries
      .where((e) => e.value >= passingGrade)
      .map((e) => e.key)
      .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate.toIso8601String(),
        'enrollmentYear': enrollmentYear,
        'enrolledCourses': enrolledCourses,
        'grades': grades,
        'skills': skills.toList()..sort(),
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        enrollmentYear: (json['enrollmentYear'] as num?)?.toInt() ?? 2023,
        enrolledCourses:
            (json['enrolledCourses'] as List?)?.cast<String>().toList(),
        grades: (json['grades'] as Map?)
            ?.map((k, v) => MapEntry(k as String, (v as num).toDouble())),
        skills: (json['skills'] as List?)?.cast<String>().toSet(),
      );

  @override
  String toString() =>
      'Student $fullName (id: $id, GPA: ${gpa.toStringAsFixed(1)}, '
      'курсів: ${enrolledCourses.length})';
}
