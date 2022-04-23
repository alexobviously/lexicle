import 'dart:math';

import 'package:common/common.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'challenge.g.dart';

/// A periodic challenge, which is the same for every at the same time, i.e. basic wordle functionality.
/// Challenges generally come in a level-sequence form, i.e. level: 0, seq: 4 is bronze challenge day 5.
/// They can also be one offs.
/// For now they can only be normal games (i.e. guess one word) but the plan is for more complex forms later.
@CopyWith()
class Challenge implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final String? fixedTitle;
  final int? level;
  final int? sequence;
  final int endTime;
  final String answer;

  // Only for API responses.
  final bool hasAttempt;

  bool get finished => endTime < nowMs();
  int get timeLeft => max(0, endTime - nowMs());
  int get length => answer.length;
  String get title {
    if (fixedTitle != null) return fixedTitle!;
    return '${Challenges.name(level)} Challenge ${(sequence ?? 0) + 1}';
  }

  Challenge({
    String? id,
    int? timestamp,
    this.fixedTitle,
    this.level,
    this.sequence,
    required this.endTime,
    required this.answer,
    this.hasAttempt = false,
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs();

  factory Challenge.fromJson(Map<String, dynamic> doc) => Challenge(
        id: parseObjectId(doc[Fields.id])!,
        timestamp: doc[Fields.timestamp] ?? nowMs(),
        fixedTitle: doc[ChallengeFields.title],
        level: doc[ChallengeFields.level],
        sequence: doc[ChallengeFields.sequence],
        endTime: doc[ChallengeFields.endTime],
        answer: doc[ChallengeFields.answer],
        hasAttempt: doc[ChallengeFields.hasAttempt] ?? false,
      );

  Map<String, dynamic> toMap({bool hideAnswer = false, bool showHasAttempt = false}) => {
        Fields.id: id,
        Fields.timestamp: timestamp,
        if (fixedTitle != null) ChallengeFields.title: fixedTitle,
        if (level != null) ChallengeFields.level: level,
        if (sequence != null) ChallengeFields.sequence: sequence,
        ChallengeFields.endTime: endTime,
        ChallengeFields.answer: hideAnswer ? ('*' * answer.length) : answer,
        if (showHasAttempt) ChallengeFields.hasAttempt: hasAttempt,
      };

  @override
  Map<String, dynamic> export() => toMap();

  @override
  String toString() => 'Challenge(id: $id, timestamp: $timestamp, level: $level, seq: $sequence, answer: $answer)';
}
