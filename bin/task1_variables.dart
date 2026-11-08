// Завдання 1: змінні, типи даних, рядки, булева логіка, колекції, null safety.

void main() {
  print('=== Dart Variables & Types Demo ===');
  demonstrateNumbers();
  demonstrateStrings();
  demonstrateBooleans();
  demonstrateCollections();
  demonstrateNullSafety();
}

void demonstrateNumbers() {
  print('\n--- Числа: int, double, num ---');
  int students = 28;
  double averageGrade = 82.75;
  num total = students * averageGrade; // num приймає і int, і double
  print('Студентів: $students, середній бал: $averageGrade, сума: $total');

  print('Ділення: 17 / 5 = ${17 / 5}, цілочисельне: 17 ~/ 5 = ${17 ~/ 5}, '
      'остача: 17 % 5 = ${17 % 5}');
  print('Бітовий зсув: 1 << 10 = ${1 << 10}');
  print('Округлення: ${3.14159.toStringAsFixed(2)}, '
      'round=${2.5.round()}, floor=${2.9.floor()}, ceil=${2.1.ceil()}');

  // Перетворення типів.
  final parsed = int.parse('42');
  final maybe = int.tryParse('не число'); // null замість винятку
  print('int.parse("42") = $parsed, int.tryParse("не число") = $maybe');
  print('double -> int: ${7.9.toInt()}, int -> double: ${7.toDouble()}');
  print('Межі: int max (64 біт) = ${9223372036854775807}, '
      'double.maxFinite = ${double.maxFinite}');
}

void demonstrateStrings() {
  print('\n--- Рядки ---');
  const name = 'Вадим';
  const group = 'АЛК-43';
  print('Інтерполяція: Студент $name з групи $group, '
      'довжина імені: ${name.length}');

  final multiLine = '''
Рядок 1
Рядок 2 (багаторядковий літерал)''';
  print(multiLine);
  print('Escape-послідовності: табуляція[\t] лапки["] апостроф[\'] '
      'зворотній слеш[\\]');
  print(r'Raw-рядок не обробляє \n і $name');

  const text = '  Dart is Optimized for UI  ';
  print('trim: "${text.trim()}"');
  print('toUpperCase: ${text.trim().toUpperCase()}');
  print('contains("UI"): ${text.contains('UI')}');
  print('replaceAll: ${text.trim().replaceAll(' ', '_')}');
  print('split: ${text.trim().split(' ')}');
  print('substring(0, 4): ${text.trim().substring(0, 4)}');
  print('padLeft: "${'7'.padLeft(3, '0')}", repeat: ${'-' * 10}');

  final buffer = StringBuffer();
  for (var i = 1; i <= 5; i++) {
    buffer.write('$i ');
  }
  print('StringBuffer: ${buffer.toString().trim()}');
}

void demonstrateBooleans() {
  print('\n--- Булева логіка та умови ---');
  const age = 19;
  const hasId = true;
  final isAdult = age >= 18;
  print('age >= 18: $isAdult, && hasId: ${isAdult && hasId}, '
      '|| !hasId: ${isAdult || !hasId}, ^ (XOR) : ${isAdult ^ hasId}');

  // Умовний (тернарний) вираз.
  final category = age < 16 ? 'підліток' : (age < 25 ? 'молодь' : 'дорослий');
  print('Категорія: $category');

  // switch-вираз (Dart 3).
  final level = switch (age) {
    < 18 => 'школяр',
    >= 18 && < 21 => 'студент молодших курсів',
    _ => 'старші курси',
  };
  print('switch-вираз: $level');

  // Порівняння об'єктів.
  print('identical("a","a"): ${identical('a', 'a')}, '
      '"abc" == "ab" + "c": ${'abc' == 'ab' 'c'}');
}

void demonstrateCollections() {
  print('\n--- List, Set, Map ---');
  final list = <int>[5, 3, 8, 1, 3];
  list.add(10);
  list.remove(8);
  list.sort();
  print('List: $list, перший: ${list.first}, останній: ${list.last}, '
      'довжина: ${list.length}, містить 3: ${list.contains(3)}');

  final set = <int>{
    ...[1, 2, 3, 3, 2]
  }; // дублікати зникають
  print('Set (унікальні): $set, перетин з {2,3,4}: ${set.intersection({
        2,
        3,
        4
      })}');

  final map = <String, int>{'Dart': 3, 'Flutter': 3, 'Kotlin': 2};
  map['Swift'] = 5;
  map.update('Kotlin', (v) => v + 1);
  print('Map: $map, ключі: ${map.keys.toList()}, '
      'значення: ${map.values.toList()}');
  map.forEach((k, v) => print('  $k -> $v'));

  final spread = [...list, ...set]; // оператор spread
  final filtered = [
    for (final x in spread)
      if (x.isEven) x * 10
  ];
  print('Spread + collection for/if: $filtered');
}

void demonstrateNullSafety() {
  print('\n--- Null safety ---');
  String? nickname = _findNickname(); // nullable: значення може бути null
  print('nickname == null: ${nickname == null}');
  print('?? : ${nickname ?? 'без псевдоніма'}');
  print('?. : ${nickname?.length}');
  nickname ??= 'dev_vadym'; // присвоїти, якщо null
  print('??= : $nickname, довжина: ${nickname.length}');

  // Паттерн: перевірка + автоматичне звуження типу.
  String? maybeCity = DateTime.now().year > 2000 ? 'Київ' : null;
  if (maybeCity != null) {
    print('Після перевірки тип String: ${maybeCity.toUpperCase()}');
  }

  // late: ініціалізація відкладається до першого використання.
  late final String config = _loadConfig();
  print('late-змінна ще не ініціалізована; звертаємось...');
  print('config = $config');

  print(describePerson(firstName: 'Вадим', lastName: 'Бойко'));
  print(describePerson(firstName: 'Вадим', lastName: 'Бойко', age: 19));
}

/// Імітація пошуку: псевдоніма в профілі ще немає.
String? _findNickname() => null;

String _loadConfig() {
  print('  (_loadConfig виконано)');
  return 'dev-mode';
}

/// required-параметри обов'язкові, age — необов'язковий nullable.
String describePerson({
  required String firstName,
  required String lastName,
  int? age,
}) =>
    '$lastName $firstName${age != null ? ', $age р.' : ', вік не вказано'}';
