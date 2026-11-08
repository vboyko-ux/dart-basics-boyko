import 'package:dart_basics_boyko/dart_basics_boyko.dart';
import 'package:test/test.dart';

Student st(String id, int year,
        {Map<String, double>? grades,
        List<String>? courses,
        Set<String>? skills}) =>
    Student(
      id: id,
      firstName: 'І$id',
      lastName: 'П$id',
      birthDate: DateTime(2005, 1, 1),
      enrollmentYear: year,
      grades: grades,
      enrolledCourses: courses ?? grades?.keys.toList(),
      skills: skills,
    );

void main() {
  group('Calculator', () {
    final calc = Calculator();

    test('базові операції', () {
      expect(calc.add(2, 3), 5);
      expect(calc.subtract(2, 3), -1);
      expect(calc.multiply(4, 2.5), 10);
      expect(calc.divide(9, 3), 3);
      expect(calc.power(2, 10), 1024);
      expect(calc.sqrt(81), 9);
    });

    test('ділення на нуль і корінь з від\'ємного', () {
      expect(() => calc.divide(1, 0), throwsArgumentError);
      expect(() => calc.sqrt(-4), throwsArgumentError);
      expect(() => calc.calculate(5, '%', 0), throwsArgumentError);
    });

    test('evaluate розбирає вираз', () {
      expect(calc.evaluate('12 + 3.5'), 15.5);
      expect(calc.evaluate('  7   %  4 '), 3);
      expect(() => calc.evaluate('1 +'), throwsFormatException);
      expect(() => calc.evaluate('1 & 2'), throwsFormatException);
      expect(() => calc.evaluate('abc + 1'), throwsFormatException);
    });
  });

  group('Функції завдання 2', () {
    test('calculateSum / calculateAverage', () {
      expect(calculateSum(7, 35), 42);
      expect(calculateAverage([1, 2, 3, 4]), 2.5);
      expect(calculateAverage([]), 0);
    });

    test('formatName: named-параметри', () {
      expect(formatName('Вадим', 'Бойко'), 'Бойко Вадим');
      expect(formatName('Вадим', 'Бойко', middleName: 'О'), 'Бойко Вадим О');
      expect(formatName('в', 'б', uppercase: true), 'Б В');
      expect(formatName('в', 'б', middleName: ''), 'б в');
    });

    test('fibonacci: ітеративний і рекурсивний збігаються', () {
      expect([for (var i = 0; i < 10; i++) fibonacci(i)],
          [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]);
      for (var i = 0; i < 15; i++) {
        expect(fibonacciRecursive(i), fibonacci(i));
      }
      expect(() => fibonacci(-1), throwsArgumentError);
      expect(() => fibonacciRecursive(-1), throwsArgumentError);
    });

    test('factorial: значення та межі', () {
      expect(factorial(0), 1);
      expect(factorial(5), 120);
      expect(factorial(20), 2432902008176640000);
      expect(() => factorial(21), throwsArgumentError);
      expect(() => factorial(-1), throwsArgumentError);
    });

    test('замикання зберігають власний стан', () {
      final a = makeCounter();
      final b = makeCounter(start: 10);
      expect([a(), a(), b()], [1, 2, 11]);
      expect(makeMultiplier(3)(7), 21);
    });
  });

  group('TextAnalyzer', () {
    test('підрахунок слів, речень, найдовшого слова', () {
      final s = TextAnalyzer.analyze('Привіт, світ! Привіт, Dart. Як справи?');
      expect(s.words, 6);
      expect(s.sentences, 3);
      expect(s.longestWord, 'привіт');
      expect(s.topWords.keys.first, 'привіт');
      expect(s.topWords['привіт'], 2);
    });

    test('порожній текст', () {
      final s = TextAnalyzer.analyze('');
      expect(s.words, 0);
      expect(s.lines, 0);
      expect(s.averageWordLength, 0);
      expect(s.longestWord, isNull);
    });

    test('символи з пробілами та без', () {
      final s = TextAnalyzer.analyze('a b\nc');
      expect(s.characters, 5);
      expect(s.charactersNoSpaces, 3);
      expect(s.lines, 2);
    });
  });

  group('DataProcessor: Lists', () {
    test('filterEvenNumbers', () {
      expect(DataProcessor.filterEvenNumbers([1, 2, 3, 4, 6, 7]), [2, 4, 6]);
      expect(DataProcessor.filterEvenNumbers([]), isEmpty);
    });

    test('countWords ігнорує регістр і пунктуацію', () {
      expect(DataProcessor.countWords('Dart, dart! Flutter.'),
          {'dart': 2, 'flutter': 1});
    });

    test('sortStudentsByGPA: спадання і ранги', () {
      final r = DataProcessor.sortStudentsByGPA([
        st('1', 2023, grades: {'A': 60}),
        st('2', 2023, grades: {'A': 90}),
        st('3', 2023, grades: {'A': 75}),
      ]);
      expect(r.map((e) => e['id']), ['2', '3', '1']);
      expect(r.map((e) => e['rank']), [1, 2, 3]);
    });
  });

  group('DataProcessor: Sets і Maps', () {
    final students = [
      st('1', 2023, courses: ['A', 'B'], skills: {'dart', 'git'}),
      st('2', 2023, courses: ['A', 'C'], skills: {'git', 'sql'}),
      st('3', 2024, courses: ['A'], skills: {}),
    ];

    test('getUniqueSkills (об\'єднання)', () {
      expect(DataProcessor.getUniqueSkills(students), {'dart', 'git', 'sql'});
    });

    test('findCommonCourses (перетин)', () {
      expect(DataProcessor.findCommonCourses(students), {'A'});
      expect(DataProcessor.findCommonCourses([]), isEmpty);
    });

    test('groupStudentsByYear', () {
      final g = DataProcessor.groupStudentsByYear(students);
      expect(g.keys, unorderedEquals(['2023', '2024']));
      expect(g['2023']!.length, 2);
    });

    test('calculateAverageGradesByCourse', () {
      final r = DataProcessor.calculateAverageGradesByCourse([
        st('1', 2023, grades: {'A': 80, 'B': 60}),
        st('2', 2023, grades: {'A': 100}),
      ]);
      expect(r, {'A': 90.0, 'B': 60.0});
    });
  });

  group('DataProcessor: звіт і CSV', () {
    test('generateReport рахує записаних і тих, що склали', () {
      final uni = University(name: 'U');
      uni.addCourse(Course(
          id: 'A',
          name: 'Курс А',
          description: '',
          credits: 1,
          instructor: 'I'));
      uni.addStudent(st('1', 2023, grades: {'A': 90}));
      uni.addStudent(st('2', 2023, grades: {'A': 40}));
      final r = DataProcessor.generateReport(uni).single;
      expect(r['enrolled'], 2);
      expect(r['passed'], 1);
      expect(r['passRate'], 50.0);
      expect(r['averageGrade'], 65.0);
    });

    test('звіт для курсу без студентів', () {
      final uni = University(name: 'U')
        ..addCourse(Course(
            id: 'A', name: 'x', description: '', credits: 1, instructor: 'I'));
      expect(DataProcessor.generateReport(uni).single['passRate'], 0.0);
    });

    const csv = '''
# коментар
id,firstName,lastName,birthDate,year,skills,courses,grades
S1,Вадим,Бойко,2006-03-14,2023,dart;git,CS101;CS102,CS101:92;CS102:85

S2,Олена,Мельник,2005-11-02,2024,,CS101,CS101:70
''';

    test('parseStudentsCsv читає поля, списки та оцінки', () {
      final s = DataProcessor.parseStudentsCsv(csv);
      expect(s.length, 2);
      expect(s.first.skills, {'dart', 'git'});
      expect(s.first.grades, {'CS101': 92.0, 'CS102': 85.0});
      expect(s.last.skills, isEmpty);
      expect(s.last.enrollmentYear, 2024);
    });

    test('CSV із помилками', () {
      expect(DataProcessor.parseStudentsCsv(''), isEmpty);
      expect(() => DataProcessor.parseStudentsCsv('h\nS1,a,b'),
          throwsFormatException);
    });
  });
}
