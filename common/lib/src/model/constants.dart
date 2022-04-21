import 'package:common/common.dart';

class Fields {
  static const id = 'id';
  static const timestamp = 'ts';
}

class GameFields {
  static const answer = 'a';
  static const player = 'p';
  static const creator = 'c';
  static const guesses = 'g';
  static const current = 'u';
  static const flags = 'f';
  static const group = 'h';
  static const challenge = 'l';
  static const finished = 'n';
  static const endTime = 't';
  static const endReason = 'r';
}

class GroupFields {
  static const title = 't';
  static const config = 'c';
  static const creator = 'x';
  static const code = 'q';
  static const state = 's';
  static const players = 'p';
  static const words = 'w';
  static const games = 'g';
  static const created = 'r';
  static const endTime = 'm';
}

// also used for Standings
class StubFields {
  static const player = 'p';
  static const progress = 'r';
  static const guesses = 'g';
  static const creator = 'c';
  static const endReason = 'e';
}

class ConfigFields {
  static const wordLength = 'l';
  static const timeLimit = 't';
  static const challengeType = 'y';
}

class WordFields {
  static const content = 'w';
  static const correct = 'c';
  static const semiCorrect = 's';
  static const finalised = 'f';
  static const difficulty = 'd';
}

class UserFields {
  static const username = 'u';
  static const auth = 'a';
  static const password = 'p';
  static const rating = 'r';
  static const deviation = 'd';
  static const team = 't';
  static const permissions = 'e';
}

class StatsFields {
  static const numGroups = 'n';
  static const numGames = 'g';
  static const guessCounts = 'c';
  static const words = 'w';
  static const wins = 'q';
  static const timeouts = 't';
}

class TeamFields {
  static const name = 'n';
  static const leader = 'l';
  static const members = 'm';
}

class ChallengeFields {
  static const title = 'i';
  static const level = 'l';
  static const sequence = 's';
  static const endTime = 't';
  static const answer = 'a';
}

class EndReasons {
  static const int solved = 0;
  static const int timeout = 1;
}

class Challenges {
  static const int bronze = 0;
  static const int silver = 1;
  static const int gold = 2;
  static const all = [bronze, silver]; // no gold just yet

  static const Map<int, int> durations = {
    bronze: oneDay,
    silver: oneDay * 3,
    gold: oneDay * 7,
  };
  static int duration(int level) => durations[level] ?? oneDay;

  static const Map<int, String> names = {
    bronze: 'Bronze',
    silver: 'Silver',
    gold: 'Gold',
  };
  static String name(int? level) => names[level] ?? 'Unknown';

  static const Map<int, GameConfig> configs = {
    bronze: GameConfig(wordLength: 6),
    silver: GameConfig(wordLength: 8),
  };
  static GameConfig config(int? level) => configs[level] ?? GameConfig.initial();
}

const int minTimeLimit = 60000;
const int oneDay = 24 * 60 * 60 * 1000;

const int defaultChallengeKey = 111111111111;
