class WordData {
  final String content;
  final List<int> correct;
  final List<int> semiCorrect;

  List<String> get correctLetters => correct.map((e) => content[e]).toList();
  List<String> get semiCorrectLetters => semiCorrect.map((e) => content[e]).toList();
  List<String> get wrongLetters =>
      content.split('')..removeWhere((e) => correctLetters.contains(e) || semiCorrectLetters.contains(e));

  const WordData({
    this.content = '',
    this.correct = const [],
    this.semiCorrect = const [],
  });
  factory WordData.current(String content) => WordData(content: content);
  factory WordData.blank() => const WordData();

  @override
  String toString() => 'WordData($content, correct: $correct, semiCorrect: $semiCorrect)';
}
