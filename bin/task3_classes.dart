// Завдання 3: ООП — система управління університетом (CRUD, спадкування, поліморфізм).
import 'package:dart_basics_boyko/dart_basics_boyko.dart';

void main() {
  print('=== University Management System Demo ===');
  runUniversityDemo();
}

void runUniversityDemo() {
  // 1. Університет.
  final uni = University(name: 'Інститут сучасних технологій');
  print('\n[1] Створено університет: ${uni.name}');

  // 2. Професори та студенти (Create).
  final professors = [
    Professor(
        id: 'P1',
        firstName: 'Олександр',
        lastName: 'Клименко',
        birthDate: DateTime(1980, 5, 20),
        department: 'Програмна інженерія',
        salary: 42000),
    Professor(
        id: 'P2',
        firstName: 'Ірина',
        lastName: 'Петренко',
        birthDate: DateTime(1975, 9, 3),
        department: 'Математика',
        salary: 38000),
  ];
  professors.forEach(
      uni.addProfessor); // ignore: avoid_function_literals_in_foreach_calls

  final students = [
    Student(
        id: 'S1',
        firstName: 'Вадим',
        lastName: 'Бойко',
        birthDate: DateTime(2006, 3, 14),
        skills: {'dart', 'flutter'}),
    Student(
        id: 'S2',
        firstName: 'Олена',
        lastName: 'Мельник',
        birthDate: DateTime(2005, 11, 2),
        skills: {'python'}),
    Student(
        id: 'S3',
        firstName: 'Андрій',
        lastName: 'Ковальчук',
        birthDate: DateTime(2006, 7, 21)),
  ];
  students.forEach(uni.addStudent);
  print('[2] Додано ${uni.professors.length} викладачів і '
      '${uni.students.length} студентів');

  // 3. Курси з передумовами.
  uni
    ..addCourse(Course(
        id: 'CS101',
        name: 'Основи програмування',
        description: 'Вступ до Dart',
        credits: 5,
        instructor: 'Клименко'))
    ..addCourse(Course(
        id: 'CS102',
        name: 'Структури даних',
        description: 'Списки, множини, мапи',
        credits: 5,
        instructor: 'Клименко',
        prerequisites: ['CS101']))
    ..addCourse(Course(
        id: 'MA101',
        name: 'Дискретна математика',
        description: 'Множини та логіка',
        credits: 4,
        instructor: 'Петренко'));
  professors[0]
    ..assignCourse('CS101')
    ..assignCourse('CS102');
  professors[1].assignCourse('MA101');
  print('[3] Курси:');
  for (final c in uni.courses) {
    print('    $c');
  }

  // 4. Запис студентів (Update) + перевірка передумов.
  print('\n[4] Запис на курси');
  for (final s in students) {
    uni.enroll(s.id, 'CS101');
  }
  uni.enroll('S1', 'MA101');
  uni.enroll('S2', 'MA101');
  try {
    uni.enroll('S1', 'CS102'); // CS101 ще не складено
  } on StateError catch (e) {
    print('    Відмова: ${e.message}');
  }

  // 5. Оцінки.
  print('\n[5] Оцінки');
  uni.findStudentById('S1')!
    ..addGrade('CS101', 92)
    ..addGrade('MA101', 85);
  uni.findStudentById('S2')!
    ..addGrade('CS101', 74)
    ..addGrade('MA101', 91);
  uni.findStudentById('S3')!.addGrade('CS101', 55);
  for (final s in uni.students) {
    print('    $s, складено: ${s.getPassedCourses()}');
  }

  // Після складання CS101 стає доступним CS102.
  final available = uni.getAvailableCoursesForStudent('S1');
  print('    Доступні для S1 тепер: ${available.map((c) => c.id).toList()}');
  uni.enroll('S1', 'CS102');

  // 6. Поліморфізм: різні нащадки Person в одному списку.
  print('\n[6] Поліморфізм (Person -> Student / Professor)');
  final people = <Person>[...professors, ...students];
  for (final p in people) {
    print('    ${p.role.padRight(9)} ${p.fullName.padRight(20)} ${p.age} р.');
  }

  // Read: пошук і вибірка за курсом.
  print('\n[7] Читання: студенти на CS101 -> '
      '${uni.getStudentsByCourse('CS101').map((s) => s.lastName).toList()}');
  print('    Студентів у викладача Клименка: '
      '${professors[0].countStudents(uni.students)}');

  // Delete.
  print('\n[8] Видалення: removeStudent("S3") -> ${uni.removeStudent('S3')}, '
      'повторно -> ${uni.removeStudent('S3')}');

  // Статистика.
  print('\n[9] Статистика:');
  uni.generateStatistics().forEach((k, v) => print('    $k: $v'));
}
