/// Результат аналізу тексту.
class TextStats {
  final int characters;
  final int charactersNoSpaces;
  final int words;
  final int sentences;
  final int lines;
  final double averageWordLength;
  final String? longestWord;
  final Map<String, int> topWords;

  const TextStats({
    required this.characters,
    required this.charactersNoSpaces,
    required this.words,
    required this.sentences,
    required this.lines,
    required this.averageWordLength,
    required this.longestWord,
    required this.topWords,
  });
}

/// Текстовий аналізатор: підрахунок слів, символів, речень, частот.
class TextAnalyzer {
  static final RegExp _wordPattern = RegExp(r"[\p{L}\p{N}']+", unicode: true);

  /// Розбиває текст на слова (літери й цифри, регістр нормалізується).
  static List<String> tokenize(String text) => _wordPattern
      .allMatches(text)
      .map((m) => m.group(0)!.toLowerCase())
      .toList();

  static TextStats analyze(String text, {int top = 5}) {
    final words = tokenize(text);
    final freq = <String, int>{};
    for (final w in words) {
      freq.update(w, (v) => v + 1, ifAbsent: () => 1);
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final totalLetters = words.fold<int>(0, (sum, w) => sum + w.length);
    String? longest;
    for (final w in words) {
      if (longest == null || w.length > longest.length) longest = w;
    }
    return TextStats(
      characters: text.length,
      charactersNoSpaces: text.replaceAll(RegExp(r'\s'), '').length,
      words: words.length,
      sentences: RegExp(r'[.!?]+').allMatches(text).length,
      lines: text.isEmpty ? 0 : text.split('\n').length,
      averageWordLength: words.isEmpty ? 0 : totalLetters / words.length,
      longestWord: longest,
      topWords: {for (final e in sorted.take(top)) e.key: e.value},
    );
  }
}
