import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'rush.g.dart';

@CopyWith()
class Rush {
  final String id;
  final int? timestamp;
  final GameConfig config;
  final Game current;
  final List<Game> completed;
  final int startTime;
  final int timeAdjustment;
  final int? endReason;

  int? get endTime => config.timeLimit != null ? startTime + config.timeLimit! + timeAdjustment : null;
  bool get finished => endReason != null;
  int get score => completed.length;
  int get length => config.wordLength;
  String get currentWord => current.word;
  int get numRows => completed.fold<int>(0, (a, b) => a + b.numRows) + current.numRows;

  Rush({
    String? id,
    int? timestamp,
    required this.config,
    required this.current,
    this.completed = const [],
    required this.startTime,
    this.timeAdjustment = 0,
    this.endReason,
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs();

  factory Rush.initial(String player, GameConfig config) => Rush(
        config: config,
        current: Game.initial(player, config.wordLength),
        startTime: nowMs(),
      );

  Rush withCurrent(Game g) => copyWith(current: g);
  Rush withNewWord(Game g) => copyWith(completed: [...completed, current], current: g);
  Rush timeAdjusted(int adjustment) => copyWith(timeAdjustment: timeAdjustment + adjustment);

  String toEmojis() {
    String output = completed.map((e) => e.toEmojis()).toList().join('\n');
    String _current = current.toEmojis();
    if (_current.isNotEmpty) output = '$output\n$_current';
    return output;
  }
}
