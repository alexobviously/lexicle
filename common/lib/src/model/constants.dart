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
}

class StatsFields {
  static const numGroups = 'n';
  static const numGames = 'g';
  static const guessCounts = 'c';
  static const words = 'w';
  static const wins = 'q';
}

class TeamFields {
  static const name = 'n';
  static const leader = 'l';
  static const members = 'm';
}

class EndReasons {
  static const int solved = 0;
  static const int timeout = 1;
}

const int minTimeLimit = 60000;
