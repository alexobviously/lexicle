import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Game implements Entity {
  @override
  final String id;
  @override
  final int timestamp;
  final String answer;
  final String player;
  final String creator;
  final List<WordData> guesses;
  final WordData current;
  final List<String> flags;
  final String? group;
  final String? challenge;
  final int? endTime; // determined in advance by timelimited games, always set on finish
  final int? endReason;
  final int penalty;

  int get length => answer.length;
  String get word => current.content;
  bool get wordReady => word.length == length;
  bool get wordEmpty => word.isEmpty;
  Set<String> get correctLetters => Set<String>.from(guesses.expand((e) => e.correctLetters));
  Set<String> get semiCorrectLetters =>
      Set<String>.from(guesses.expand((e) => e.semiCorrectLetters))..removeWhere((e) => correctLetters.contains(e));
  Set<String> get wrongLetters => Set<String>.from(guesses.expand((e) => e.wrongLetters));
  bool get solved => guesses.isNotEmpty && guesses.last.solved;
  bool get gameFinished => endReason != null;
  int get numRows => guesses.length + (gameFinished ? 0 : 1);
  bool get invalid => flags.contains(flagInvalid);
  double get progress => gameFinished ? 1.0 : (correctLetters.length * 2 + semiCorrectLetters.length) / (length * 2);
  int get score => guesses.length + penalty;
  GameStub get stub => GameStub(
        id: id,
        creator: creator,
        progress: progress,
        guesses: score,
        endReason: endReason,
      );

  Game({
    String? id,
    int? timestamp,
    required this.answer,
    required this.player,
    String? creator,
    required this.guesses,
    required this.current,
    this.flags = const [],
    this.group,
    this.challenge,
    this.endTime,
    this.endReason,
    this.penalty = 0,
  })  : id = id ?? ObjectId().id.hexString,
        timestamp = timestamp ?? nowMs(),
        creator = creator ?? player;

  factory Game.initial(String player, int length, {String? creator, String? id, int? endTime}) => Game(
        answer: '*' * length,
        guesses: [],
        current: WordData.blank(),
        player: player,
        creator: creator,
        id: id,
        endTime: endTime,
      );

  factory Game.fromChallenge({required Challenge challenge, required String player}) => Game(
        answer: challenge.answer,
        endTime: challenge.endTime,
        player: player,
        guesses: [],
        current: WordData.blank(),
      );

  static const flagInvalid = 'i';

  factory Game.fromJson(Map<String, dynamic> doc) {
    return Game(
      id: parseObjectId(doc[Fields.id]),
      timestamp: doc[Fields.timestamp] ?? nowMs(),
      answer: doc[GameFields.answer],
      player: doc[GameFields.player],
      creator: doc[GameFields.creator],
      guesses:
          (doc[GameFields.guesses] as List).map<WordData>((e) => WordData.fromJson(e as Map<String, dynamic>)).toList(),
      current: WordData.fromJson(doc[GameFields.current] as Map<String, dynamic>),
      flags: coerceList(doc[GameFields.flags] ?? []),
      group: doc[GameFields.group],
      challenge: doc[GameFields.challenge],
      endTime: doc[GameFields.endTime],
      endReason: doc[GameFields.endReason],
    );
  }

  Map<String, dynamic> toMap({bool hideAnswer = false, bool hideGuesses = false}) {
    return {
      Fields.id: parseObjectId(id),
      Fields.timestamp: timestamp,
      GameFields.answer: hideAnswer ? ('*' * answer.length) : answer,
      GameFields.player: player,
      GameFields.creator: creator,
      GameFields.guesses: guesses.map((e) => e.toMap(hideContent: hideGuesses)).toList(),
      GameFields.current: current.toMap(hideContent: hideAnswer),
      GameFields.flags: flags,
      if (group != null) GameFields.group: group,
      if (challenge != null) GameFields.challenge: challenge,
      if (endTime != null) GameFields.endTime: endTime,
      if (endReason != null) GameFields.endReason: endReason,
    };
  }

  @override
  Map<String, dynamic> export() {
    Map<String, dynamic> _map = toMap();
    _map[GameFields.finished] = gameFinished; // for queries
    return _map;
  }

  Game copyWith({
    String? id,
    String? answer,
    String? player,
    String? creator,
    List<WordData>? guesses,
    WordData? current,
    List<String> flags = const [],
    String? group,
    int? endTime,
    int? endReason,
    int? penalty,
  }) {
    return Game(
      id: id ?? this.id,
      answer: answer ?? this.answer,
      player: player ?? this.player,
      creator: creator ?? this.creator,
      guesses: guesses ?? this.guesses,
      current: current ?? this.current,
      flags: flags,
      group: group ?? this.group,
      endTime: endTime ?? this.endTime,
      endReason: endReason ?? this.endReason,
      penalty: penalty ?? this.penalty,
    );
  }

  Game copyWithFlags(List<String> flags) => copyWith(flags: flags);
  Game copyWithInvalid() => copyWith(flags: [flagInvalid]);

  @override
  String toString() => 'Game($id, player; $player, creator: $creator, answer: $answer, guesses: ${guesses.length})';

  String toEmojis() {
    String _emojiAt(WordData word, int index) {
      if (word.correct.contains(index)) return '🟩';
      if (word.semiCorrect.contains(index)) return '🟨';
      return '⬛';
    }

    if (guesses.isEmpty) return '';
    final range = List.generate(length, (i) => i);
    List<String> lines = guesses.map((e) => range.map((i) => _emojiAt(e, i)).join('')).toList();
    return lines.join('\n');
  }
}
