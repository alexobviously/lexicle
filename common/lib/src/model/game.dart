// ignore_for_file: unnecessary_this

import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Game implements Entity {
  @override
  final String id;
  final String answer;
  final String player;
  final String creator;
  final List<WordData> guesses;
  final WordData current;
  final List<String> flags;
  final String? group;

  int get length => answer.length;
  String get word => current.content;
  bool get wordReady => word.length == length;
  bool get wordEmpty => word.isEmpty;
  Set<String> get correctLetters => Set<String>.from(guesses.expand((e) => e.correctLetters));
  Set<String> get semiCorrectLetters =>
      Set<String>.from(guesses.expand((e) => e.semiCorrectLetters))..removeWhere((e) => correctLetters.contains(e));
  Set<String> get wrongLetters => Set<String>.from(guesses.expand((e) => e.wrongLetters));
  bool get gameFinished => guesses.isNotEmpty && guesses.last.correctLetters.length == length;
  int get numRows => guesses.length + (gameFinished ? 0 : 1);
  bool get invalid => flags.contains(flagInvalid);
  double get progress => gameFinished ? 1.0 : (correctLetters.length * 2 + semiCorrectLetters.length) / (length * 2);
  GameStub get stub => GameStub(id: id, creator: creator, progress: progress, guesses: guesses.length);

  Game({
    String? id,
    required this.answer,
    required this.player,
    String? creator,
    required this.guesses,
    required this.current,
    this.flags = const [],
    this.group,
  })  : this.id = id ?? ObjectId().id.hexString,
        this.creator = creator ?? player;

  factory Game.initial(String player, int length, {String? creator, String? id}) => Game(
        answer: '*' * length,
        guesses: [],
        current: WordData.blank(),
        player: player,
        creator: creator,
        id: id,
      );

  static const flagInvalid = 'i';

  factory Game.fromJson(Map<String, dynamic> doc) {
    return Game(
      id: parseObjectId(doc[Fields.id]),
      answer: doc[GameFields.answer],
      player: doc[GameFields.player],
      creator: doc[GameFields.creator],
      guesses:
          (doc[GameFields.guesses] as List).map<WordData>((e) => WordData.fromJson(e as Map<String, dynamic>)).toList(),
      current: WordData.fromJson(doc[GameFields.current] as Map<String, dynamic>),
      flags: coerceList(doc[GameFields.flags] ?? []),
    );
  }

  Map<String, dynamic> toMap({bool hideAnswer = false}) {
    return {
      Fields.id: parseObjectId(id),
      GameFields.answer: hideAnswer ? ('*' * answer.length) : answer,
      GameFields.player: player,
      GameFields.creator: creator,
      GameFields.guesses: guesses.map((e) => e.toMap()).toList(),
      GameFields.current: current.toMap(),
      GameFields.flags: flags,
      if (group != null) GameFields.group: group,
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
    );
  }

  Game copyWithFlags(List<String> flags) => copyWith(flags: flags);
  Game copyWithInvalid() => copyWith(flags: [flagInvalid]);

  @override
  String toString() => 'Game($id, player; $player, creator: $creator, answer: $answer, guesses: ${guesses.length})';
}
