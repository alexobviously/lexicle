import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

@CopyWith()
class Challenge implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final int level;
  final int endTime;
  final String answer;

  bool get finished => endTime < nowMs();
  int get length => answer.length;

  Challenge({
    String? id,
    int? timestamp,
    required this.level,
    required this.endTime,
    required this.answer,
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs();

  factory Challenge.fromJson(Map<String, dynamic> doc) => Challenge(
        id: parseObjectId(doc[Fields.id])!,
        timestamp: doc[Fields.timestamp] ?? nowMs(),
        level: doc[ChallengeFields.level],
        endTime: doc[ChallengeFields.endTime],
        answer: doc[ChallengeFields.answer],
      );

  Map<String, dynamic> toMap({bool hideAnswer = false}) => {
        Fields.id: id,
        Fields.timestamp: timestamp,
        ChallengeFields.level: level,
        ChallengeFields.endTime: endTime,
        ChallengeFields.answer: hideAnswer ? ('*' * answer.length) : answer,
      };

  @override
  Map<String, dynamic> export() => toMap();

  @override
  String toString() => 'Challenge(id: $id, timestamp: $timestamp, level: $level, answer: $answer)';
}
