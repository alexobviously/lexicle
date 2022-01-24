import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'word_data.g.dart';

@CopyWith()
class WordData {
  final String content;
  final List<int> correct;
  final List<int> semiCorrect;
  final bool finalised;

  List<String> get correctLetters => correct.map((e) => content[e]).toList();
  List<String> get semiCorrectLetters => semiCorrect.map((e) => content[e]).toList();
  List<String> get wrongLetters =>
      content.split('')..removeWhere((e) => correctLetters.contains(e) || semiCorrectLetters.contains(e));
  bool get isCorrect => content.length == correct.length;

  const WordData({
    this.content = '',
    this.correct = const [],
    this.semiCorrect = const [],
    this.finalised = false,
  });
  factory WordData.current(String content) => WordData(content: content);
  factory WordData.blank() => const WordData();

  static const __content = 'w';
  static const __correct = 'c';
  static const __semiCorrect = 's';
  static const __finalised = 'f';

  factory WordData.fromJson(Map<String, dynamic> doc) => WordData(
        content: doc[__content],
        correct: coerceList<int>(doc[__correct] ?? []),
        semiCorrect: coerceList<int>(doc[__semiCorrect] ?? []),
        finalised: doc['finalised'] as bool? ?? true,
      );

  Map<String, dynamic> toMap({bool showFinalised = false}) {
    return {
      __content: content,
      __correct: correct,
      __semiCorrect: semiCorrect,
      if (showFinalised) __finalised: finalised,
    };
  }

  @override
  String toString() => 'WordData($content, correct: $correct, semiCorrect: $semiCorrect, finalised: $finalised)';
}
