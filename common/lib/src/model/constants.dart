class Fields {
  static const id = 'id';
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
}

// also used for Standings
class StubFields {
  static const player = 'p';
  static const progress = 'r';
  static const guesses = 'g';
  static const creator = 'c';
}

class ConfigFields {
  static const wordLength = 'l';
}

class WordFields {
  static const content = 'w';
  static const correct = 'c';
  static const semiCorrect = 's';
  static const finalised = 'f';
}
