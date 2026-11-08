// Консольний текстовий аналізатор. Запуск:
//   dart run bin/text_analyzer_app.dart                       (data/sample_text.txt)
//   dart run bin/text_analyzer_app.dart шлях/до/файлу.txt
import 'dart:io';

import 'package:dart_basics_boyko/dart_basics_boyko.dart';

void main(List<String> args) {
  final path = args.isNotEmpty ? args.first : 'data/sample_text.txt';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Файл не знайдено: $path');
    exitCode = 2;
    return;
  }
  final text = file.readAsStringSync();
  final stats = TextAnalyzer.analyze(text, top: 5);

  print('=== Текстовий аналізатор: $path ===');
  print('Символів (усього):       ${stats.characters}');
  print('Символів (без пробілів): ${stats.charactersNoSpaces}');
  print('Слів:                    ${stats.words}');
  print('Речень:                  ${stats.sentences}');
  print('Рядків:                  ${stats.lines}');
  print(
      'Середня довжина слова:   ${stats.averageWordLength.toStringAsFixed(2)}');
  print('Найдовше слово:          ${stats.longestWord}');
  print('Топ-5 слів:');
  stats.topWords.forEach((w, n) => print('  ${w.padRight(14)} $n'));
}
