// ignore_for_file: unnecessary_this

import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Game {
  final String id;
  final String answer;
  final String player;
  final String creator;
  final List<WordData> guesses;
  final WordData current;
  final List<String> flags;

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

  Game({
    String? id,
    required this.answer,
    required this.player,
    String? creator,
    required this.guesses,
    required this.current,
    this.flags = const [],
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

  static const __id = 'id';
  static const __answer = 'a';
  static const __player = 'p';
  static const __creator = 'c';
  static const __guesses = 'g';
  static const __current = 'u';
  static const __flags = 'f';
  static const flagInvalid = 'i';

  factory Game.fromJson(Map<String, dynamic> doc) {
    return Game(
      id: parseObjectId(doc[__id]),
      answer: doc[__answer],
      player: doc[__player],
      creator: doc[__creator],
      guesses: (doc[__guesses] as List).map<WordData>((e) => WordData.fromJson(e as Map<String, dynamic>)).toList(),
      current: WordData.fromJson(doc[__current] as Map<String, dynamic>),
      flags: coerceList(doc[__flags] ?? []),
    );
  }

  Map<String, dynamic> toMap({bool hideAnswer = false}) {
    return {
      __id: id,
      __answer: hideAnswer ? ('*' * answer.length) : answer,
      __player: player,
      __creator: creator,
      __guesses: guesses.map((e) => e.toMap()).toList(),
      __current: current.toMap(),
      __flags: flags,
    };
  }

  Game copyWith({
    String? id,
    String? answer,
    String? player,
    String? creator,
    List<WordData>? guesses,
    WordData? current,
    List<String> flags = const [],
  }) {
    return Game(
      id: id ?? this.id,
      answer: answer ?? this.answer,
      player: player ?? this.player,
      creator: creator ?? this.creator,
      guesses: guesses ?? this.guesses,
      current: current ?? this.current,
      flags: flags,
    );
  }

  Game copyWithFlags(List<String> flags) => copyWith(flags: flags);
  Game copyWithInvalid() => copyWith(flags: [flagInvalid]);
}
