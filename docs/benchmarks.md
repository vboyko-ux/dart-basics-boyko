# Бенчмарки

Середній час (мкс) після прогріву; Dart 3.13.7, windows. Команда: `dart run bin/benchmark.dart`.

| Операція | Обсяг | Час, мкс |
|---|---|---:|
| fibonacci(30) ітеративно | n=30 | 0.38 |
| fibonacciRecursive(30) | n=30 | 4974 |
| sortStudentsByGPA | n=1000 | 2322 |
| groupStudentsByYear | n=1000 | 318 |
| calculateAverageGradesByCourse | n=1000 | 1116 |
| getUniqueSkills (Set) | n=1000 | 482 |
| sortStudentsByGPA | n=10000 | 10297 |
| groupStudentsByYear | n=10000 | 422 |
| calculateAverageGradesByCourse | n=10000 | 2092 |
| getUniqueSkills (Set) | n=10000 | 325 |
| sortStudentsByGPA | n=100000 | 307665 |
| groupStudentsByYear | n=100000 | 8462 |
| calculateAverageGradesByCourse | n=100000 | 26041 |
| getUniqueSkills (Set) | n=100000 | 6277 |
| TextAnalyzer.analyze | 194999 симв. | 63694 |
| DataProcessor.countWords | 194999 симв. | 40797 |
| List.contains ×1000 | n=20000 | 8414 |
| Set.contains ×1000 | n=20000 | 112 |
| 5 запитів послідовно (100 мс кожен) | async | 555951 |
| 5 запитів Future.wait (100 мс кожен) | async | 119336 |
