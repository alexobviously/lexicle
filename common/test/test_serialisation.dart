import 'dart:convert';
import 'dart:math';

import 'package:common/common.dart';
import 'package:test/test.dart';

void main() {
  group('From JSON', () {
    for (final t in gameTests) {
      test('FromJson: ${t.json}', () {
        Game g = Game.fromJson(jsonDecode(t.json));
        expect(g.gameFinished, t.gameFinished);
        if (t.numGuesses != null) {
          expect(g.guesses.length, t.numGuesses);
        }
        if (t.current != null) {
          expect(g.word, t.current);
        }
        expect(g.invalid, t.invalid);
        if (t.numCorrect != null) {
          expect(g.correctLetters.length, t.numCorrect);
        }
        if (t.numSemiCorrect != null) {
          expect(g.semiCorrectLetters.length, t.numSemiCorrect);
        }
        if (t.numWrong != null) {
          expect(g.wrongLetters.length, t.numWrong);
        }
      });
    }
  });
}

List<GameSerialisationTest> gameTests = [
  GameSerialisationTest(
    json:
        '{"id":"61ee406707b9759e63a05961","a":"*****","p":"player","c":"player","g":[{"w":"train","c":[],"s":[0]},{"w":"poles","c":[],"s":[2,3]},{"w":"cleft","c":[1,2,4],"s":[0]}],"u":{"w":"","c":[],"s":[]},"f":[]}',
    numGuesses: 3,
    numCorrect: 3,
    numSemiCorrect: 1,
    numWrong: 8,
  ),
  GameSerialisationTest(
    json:
        '{"id":"61ee40fe07b9759e63a05962","a":"*****","p":"player","c":"player","g":[{"w":"belts","c":[0],"s":[4]},{"w":"brash","c":[0],"s":[2,3]},{"w":"basic","c":[0,1,2,3,4],"s":[]}],"u":{"w":"","c":[],"s":[]},"f":[]}',
    gameFinished: true,
    numGuesses: 3,
  ),
  GameSerialisationTest(
    json:
        '{"id":"61ee43b707b9759e63a05963","a":"*****","p":"player","c":"player","g":[{"w":"proxy","c":[2],"s":[1]}],"u":{"w":"ran","c":[],"s":[]},"f":[]}',
    numGuesses: 1,
    current: 'ran',
  ),
  GameSerialisationTest(
    json:
        '{"id":"61ee44d007b9759e63a05964","a":"*****","p":"player","c":"player","g":[{"w":"loads","c":[],"s":[]},{"w":"thank","c":[],"s":[]}],"u":{"w":"zzzzz","c":[],"s":[]},"f":["i"]}',
    numGuesses: 2,
    current: 'zzzzz',
    invalid: true,
  ),
];

// note: if Game serialisation works, then WordData is also fine
class GameSerialisationTest {
  final String json;
  final bool gameFinished;
  final int? numGuesses;
  final String? current;
  final bool invalid;
  final int? numCorrect;
  final int? numSemiCorrect;
  final int? numWrong;

  GameSerialisationTest({
    required this.json,
    this.gameFinished = false,
    this.numGuesses,
    this.current,
    this.invalid = false,
    this.numCorrect,
    this.numSemiCorrect,
    this.numWrong,
  });
}
