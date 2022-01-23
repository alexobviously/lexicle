import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_config.g.dart';

@CopyWith()
class GameConfig {
  final int wordLength;
  const GameConfig({required this.wordLength});
  GameConfig.initial() : this(wordLength: 5);
}
