/// Абстрактна особа: спільна основа для студента й викладача.
abstract class Person {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;

  Person({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  /// Повне ім'я (прізвище та ім'я).
  String get fullName => '$lastName $firstName';

  /// Вік на сьогодні.
  int get age => ageOn(DateTime.now());

  /// Вік на задану дату (окремий метод, щоб код легко тестувався).
  int ageOn(DateTime date) {
    var years = date.year - birthDate.year;
    final hadBirthday = date.month > birthDate.month ||
        (date.month == birthDate.month && date.day >= birthDate.day);
    if (!hadBirthday) years--;
    return years;
  }

  /// Роль у університеті (абстрактний getter, кожен нащадок задає свою).
  String get role;

  @override
  String toString() => '$role $fullName (id: $id, $age р.)';
}
