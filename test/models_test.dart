import 'package:dart_basics_boyko/dart_basics_boyko.dart';
import 'package:test/test.dart';

Student makeStudent(String id,
        {Map<String, double>? grades, List<String>? courses}) =>
    Student(
      id: id,
      firstName: 'Ім$id',
      lastName: 'Пр$id',
      birthDate: DateTime(2005, 6, 15),
      grades: grades,
      enrolledCourses: courses,
    );

void main() {
  group('Person / Student', () {
    test('ageOn враховує день народження', () {
      final s = makeStudent('1');
      expect(s.ageOn(DateTime(2025, 6, 14)), 19);
      expect(s.ageOn(DateTime(2025, 6, 15)), 20);
      expect(s.ageOn(DateTime(2026, 1, 1)), 20);
    });

    test('fullName і role', () {
      final s = makeStudent('1');
      expect(s.fullName, 'Пр1 Ім1');
      expect(s.role, 'Student');
    });

    test('gpa порожній = 0, інакше середнє', () {
      expect(makeStudent('1').gpa, 0);
      final s =
          makeStudent('2', grades: {'A': 80, 'B': 100}, courses: ['A', 'B']);
      expect(s.gpa, 90);
    });

    test('enrollInCourse не дублює записи', () {
      final s = makeStudent('1')
        ..enrollInCourse('CS101')
        ..enrollInCourse('CS101');
      expect(s.enrolledCourses, ['CS101']);
    });

    test('addGrade валідує діапазон і запис на курс', () {
      final s = makeStudent('1')..enrollInCourse('CS101');
      s.addGrade('CS101', 77);
      expect(s.grades['CS101'], 77);
      expect(() => s.addGrade('CS101', 101), throwsRangeError);
      expect(() => s.addGrade('CS101', -1), throwsRangeError);
      expect(() => s.addGrade('XX', 50), throwsStateError);
    });

    test('getPassedCourses: поріг 60 включно', () {
      final s = makeStudent('1',
          grades: {'A': 60, 'B': 59.9, 'C': 100}, courses: ['A', 'B', 'C']);
      expect(s.getPassedCourses(), unorderedEquals(['A', 'C']));
    });

    test('toJson / fromJson — круговий обмін', () {
      final s = Student(
        id: 'S9',
        firstName: 'Тест',
        lastName: 'Тестенко',
        birthDate: DateTime(2004, 2, 29),
        enrollmentYear: 2022,
        enrolledCourses: ['CS101'],
        grades: {'CS101': 88.5},
        skills: {'dart', 'git'},
      );
      final copy = Student.fromJson(s.toJson());
      expect(copy.toJson(), s.toJson());
      expect(copy.skills, {'dart', 'git'});
      expect(copy.birthDate, DateTime(2004, 2, 29));
    });
  });

  group('Course', () {
    final course = Course(
        id: 'CS102',
        name: 'Структури даних',
        description: 'd',
        credits: 5,
        instructor: 'X',
        prerequisites: ['CS101']);

    test('hasPrerequisites', () {
      expect(course.hasPrerequisites(), isTrue);
      expect(
          Course(
                  id: 'a',
                  name: 'a',
                  description: '',
                  credits: 1,
                  instructor: 'x')
              .hasPrerequisites(),
          isFalse);
    });

    test('canStudentEnroll вимагає складеної передумови', () {
      final without = makeStudent('1');
      final failed =
          makeStudent('2', grades: {'CS101': 40}, courses: ['CS101']);
      final passed =
          makeStudent('3', grades: {'CS101': 75}, courses: ['CS101']);
      expect(course.canStudentEnroll(without), isFalse);
      expect(course.canStudentEnroll(failed), isFalse);
      expect(course.canStudentEnroll(passed), isTrue);
    });

    test('вже записаний студент не може записатися повторно', () {
      final s =
          makeStudent('1', grades: {'CS101': 90}, courses: ['CS101', 'CS102']);
      expect(course.canStudentEnroll(s), isFalse);
    });

    test('toString містить передумови', () {
      expect(course.toString(), contains('потрібно: CS101'));
    });
  });

  group('University', () {
    late University uni;
    setUp(() {
      uni = University(name: 'Тест');
      uni.addCourse(Course(
          id: 'CS101',
          name: 'Base',
          description: '',
          credits: 5,
          instructor: 'P'));
      uni.addCourse(Course(
          id: 'CS102',
          name: 'Adv',
          description: '',
          credits: 5,
          instructor: 'P',
          prerequisites: ['CS101']));
      uni.addStudent(makeStudent('1'));
      uni.addStudent(makeStudent('2'));
    });

    test('CRUD: дублікати відхиляються', () {
      expect(() => uni.addStudent(makeStudent('1')), throwsArgumentError);
      expect(
          () => uni.addCourse(Course(
              id: 'CS101',
              name: 'x',
              description: '',
              credits: 1,
              instructor: 'x')),
          throwsArgumentError);
    });

    test('findStudentById / findCourseById', () {
      expect(uni.findStudentById('2')?.id, '2');
      expect(uni.findStudentById('нема'), isNull);
      expect(uni.findCourseById('CS102')?.name, 'Adv');
      expect(uni.findCourseById('нема'), isNull);
    });

    test('enroll перевіряє передумови та існування', () {
      uni.enroll('1', 'CS101');
      expect(() => uni.enroll('1', 'CS102'), throwsStateError);
      expect(() => uni.enroll('нема', 'CS101'), throwsStateError);
      expect(() => uni.enroll('1', 'нема'), throwsStateError);
      uni.findStudentById('1')!.addGrade('CS101', 80);
      uni.enroll('1', 'CS102');
      expect(uni.getStudentsByCourse('CS102').map((s) => s.id), ['1']);
    });

    test('getAvailableCoursesForStudent', () {
      expect(
          uni.getAvailableCoursesForStudent('1').map((c) => c.id), ['CS101']);
      expect(uni.getAvailableCoursesForStudent('нема'), isEmpty);
    });

    test('removeStudent повертає true лише для існуючого', () {
      expect(uni.removeStudent('1'), isTrue);
      expect(uni.removeStudent('1'), isFalse);
      expect(uni.students.length, 1);
    });

    test('generateStatistics', () {
      uni.enroll('1', 'CS101');
      uni.enroll('2', 'CS101');
      uni.findStudentById('1')!.addGrade('CS101', 90);
      uni.findStudentById('2')!.addGrade('CS101', 70);
      final stats = uni.generateStatistics();
      expect(stats['students'], 2);
      expect(stats['averageGpa'], 80.0);
      expect(stats['bestStudent'], 'Пр1 Ім1');
      expect(stats['totalEnrollments'], 2);
    });

    test('статистика порожнього університету не падає', () {
      final stats = University(name: 'Пустий').generateStatistics();
      expect(stats['averageGpa'], 0.0);
      expect(stats['bestStudent'], isNull);
    });
  });

  group('Professor і поліморфізм', () {
    test('Professor — це Person із role Professor', () {
      final p = Professor(
          id: 'P1',
          firstName: 'О',
          lastName: 'К',
          birthDate: DateTime(1980, 1, 1),
          department: 'ПІ',
          salary: 1000);
      final Person asPerson = p;
      expect(asPerson.role, 'Professor');
      p
        ..assignCourse('CS101')
        ..assignCourse('CS101');
      expect(p.taughtCourses, ['CS101']);
    });

    test('countStudents рахує студентів на курсах викладача', () {
      final p = Professor(
          id: 'P1',
          firstName: 'О',
          lastName: 'К',
          birthDate: DateTime(1980, 1, 1),
          department: 'ПІ',
          salary: 1000,
          taughtCourses: ['CS101']);
      final students = [
        makeStudent('1', courses: ['CS101']),
        makeStudent('2', courses: ['MA101']),
        makeStudent('3', courses: ['CS101', 'MA101']),
      ];
      expect(p.countStudents(students), 2);
    });
  });
}
