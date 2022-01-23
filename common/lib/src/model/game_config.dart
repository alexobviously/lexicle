import 'package:copy_with_extension/copy_with_extension.dart';

part 'game_config.g.dart';

@CopyWith()
class GameConfig {
  final int wordLength;
  GameConfig({required this.wordLength});
}
