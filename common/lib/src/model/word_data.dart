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
  bool get solved => content.length == correct.length;

  const WordData({
    this.content = '',
    this.correct = const [],
    this.semiCorrect = const [],
    this.finalised = false,
  });
  factory WordData.current(String content) => WordData(content: content);
  factory WordData.blank() => const WordData();

  factory WordData.fromJson(Map<String, dynamic> doc) => WordData(
        content: doc[WordFields.content],
        correct: coerceList<int>(doc[WordFields.correct] ?? []),
        semiCorrect: coerceList<int>(doc[WordFields.semiCorrect] ?? []),
        finalised: doc[WordFields.finalised] as bool? ?? true,
      );

  Map<String, dynamic> toMap({bool showFinalised = false, bool hideContent = false}) {
    return {
      WordFields.content: hideContent ? ' ' * content.length : content,
      WordFields.correct: correct,
      WordFields.semiCorrect: semiCorrect,
      if (showFinalised) WordFields.finalised: finalised,
    };
  }

  @override
  String toString() => 'WordData($content, correct: $correct, semiCorrect: $semiCorrect, finalised: $finalised)';
}
