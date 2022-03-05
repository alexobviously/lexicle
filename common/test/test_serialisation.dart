import 'dart:convert';

import 'package:common/common.dart';
import 'package:test/test.dart';

void main() {
  group('Game.fromJson', () {
    for (final t in gameTests) {
      test('Game.fromJson: ${t.json}', () {
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

  group('GameGroup.fromJson', () {
    for (final t in groupTests) {
      test('GameGroup.fromJson: ${t.json}', () {
        GameGroup g = GameGroup.fromJson(jsonDecode(t.json));
        expect(g.canBegin, t.canBegin);
        if (t.numPlayers != null) {
          expect(g.players.length, t.numPlayers);
        }
        if (g.state > GroupState.lobby && t.numPlayers != null) {
          int nGames = g.games[g.players.first]!.length;
          if (nGames != t.numPlayers! - 1) {
            fail('Player ${g.players.first} has wrong number of games');
          }
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

List<GroupSerialisationTest> groupTests = [
  GroupSerialisationTest(
    json: '{"id":"61ee485d4ea6bbe821865954","t":"testgroup","c":{"l":5},"x":"alex","s":0,"p":["alex"],"w":{},"g":{}}',
    numPlayers: 1,
  ),
  GroupSerialisationTest(
    json:
        '{"id":"61ee4a69079a6ec4b341b396","t":"testgroup2","c":{"l":5},"x":"alex","s":0,"p":["alex","steve"],"w":{},"g":{}}',
    numPlayers: 2,
  ),
  GroupSerialisationTest(
    json:
        '{"id":"61ee4a9a751a6abc165754a0","t":"testgroup2","c":{"l":5},"x":"alex","s":0,"p":["alex","steve"],"w":{"alex":"proxy","steve":"about"},"g":{}}',
    numPlayers: 2,
    canBegin: true,
  ),
  GroupSerialisationTest(
    json:
        '{"id":"61ee4c3a0b375909f3d702d6","t":"ubfbfccswo","c":{"l":5},"x":"alex","s":1,"p":["alex","steve","gary"],"w":{"alex":"proxy","steve":"about","gary":"adieu"},"g":{"alex":["123123","123124"],"steve":["444444","444445"],"gary":["666666","666667"]}}',
    numPlayers: 3,
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

class GroupSerialisationTest {
  final String json;
  final bool canBegin;
  final int? numPlayers;

  GroupSerialisationTest({required this.json, this.canBegin = false, this.numPlayers});
}
