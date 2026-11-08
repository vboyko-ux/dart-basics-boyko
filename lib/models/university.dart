import 'course.dart';
import 'person.dart';
import 'student.dart';

export 'person.dart';

/// Викладач: нащадок [Person] з кафедрою, курсами та окладом.
class Professor extends Person {
  final String department;
  final List<String> taughtCourses;
  final double salary;

  Professor({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required this.department,
    required this.salary,
    List<String>? taughtCourses,
  }) : taughtCourses = taughtCourses ?? [];

  @override
  String get role => 'Professor';

  /// Призначає викладача на курс (без дублікатів).
  void assignCourse(String courseId) {
    if (!taughtCourses.contains(courseId)) taughtCourses.add(courseId);
  }

  /// Кількість студентів, які слухають курси викладача.
  int countStudents(Iterable<Student> students) => students
      .where((s) => s.enrolledCourses.any(taughtCourses.contains))
      .length;
}

/// Університет: колекції людей і курсів та CRUD-операції над ними.
class University {
  final String name;
  final List<Student> students;
  final List<Professor> professors;
  final List<Course> courses;

  University({
    required this.name,
    List<Student>? students,
    List<Professor>? professors,
    List<Course>? courses,
  })  : students = students ?? [],
        professors = professors ?? [],
        courses = courses ?? [];

  // ---- Create ----
  void addStudent(Student student) {
    if (findStudentById(student.id) != null) {
      throw ArgumentError('Студент з id ${student.id} уже існує');
    }
    students.add(student);
  }

  void addProfessor(Professor professor) => professors.add(professor);

  void addCourse(Course course) {
    if (findCourseById(course.id) != null) {
      throw ArgumentError('Курс ${course.id} уже існує');
    }
    courses.add(course);
  }

  // ---- Read ----
  Student? findStudentById(String id) {
    for (final s in students) {
      if (s.id == id) return s;
    }
    return null;
  }

  Course? findCourseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Student> getStudentsByCourse(String courseId) =>
      students.where((s) => s.enrolledCourses.contains(courseId)).toList();

  List<Course> getAvailableCoursesForStudent(String studentId) {
    final student = findStudentById(studentId);
    if (student == null) return [];
    return courses.where((c) => c.canStudentEnroll(student)).toList();
  }

  // ---- Update ----
  /// Записує студента на курс, перевіряючи передумови.
  void enroll(String studentId, String courseId) {
    final student = findStudentById(studentId);
    final course = findCourseById(courseId);
    if (student == null) throw StateError('Студента $studentId не знайдено');
    if (course == null) throw StateError('Курс $courseId не знайдено');
    if (!course.canStudentEnroll(student)) {
      throw StateError(
          '${student.fullName} не може записатися на ${course.name}');
    }
    student.enrollInCourse(courseId);
  }

  // ---- Delete ----
  /// Видаляє студента; повертає true, якщо такий був.
  bool removeStudent(String studentId) {
    final before = students.length;
    students.removeWhere((s) => s.id == studentId);
    return students.length < before;
  }

  /// Зведена статистика університету.
  Map<String, dynamic> generateStatistics() {
    final graded = students.where((s) => s.grades.isNotEmpty).toList();
    final avgGpa = graded.isEmpty
        ? 0.0
        : graded.map((s) => s.gpa).reduce((a, b) => a + b) / graded.length;
    final best = graded.isEmpty
        ? null
        : graded.reduce((a, b) => a.gpa >= b.gpa ? a : b);
    return {
      'university': name,
      'students': students.length,
      'professors': professors.length,
      'courses': courses.length,
      'averageGpa': double.parse(avgGpa.toStringAsFixed(2)),
      'bestStudent': best?.fullName,
      'totalEnrollments':
          students.fold<int>(0, (sum, s) => sum + s.enrolledCourses.length),
    };
  }
}
