# Покриття тестами

Команди:

```bash
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
node tools/coverage_summary.js
```

| Файл | Покрито рядків | Усього рядків | % |
|---|---:|---:|---:|
| lib/models/course.dart | 10 | 10 | 100.0 |
| lib/models/person.dart | 7 | 10 | 70.0 |
| lib/models/student.dart | 40 | 44 | 90.9 |
| lib/models/university.dart | 58 | 59 | 98.3 |
| lib/utils/async_service.dart | 27 | 27 | 100.0 |
| lib/utils/calculator.dart | 52 | 56 | 92.9 |
| lib/utils/data_processor.dart | 79 | 79 | 100.0 |
| lib/utils/text_analyzer.dart | 26 | 26 | 100.0 |
| **Разом** | **299** | **311** | **96.1** |
