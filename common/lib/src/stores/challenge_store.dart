import 'package:common/common.dart';

class ChallengeStore extends EntityStore<Challenge> {
  final Dictionary dictionary;
  final int? key;
  bool get isAuthority => key != null;

  ChallengeStore(
    DatabaseService db, {
    required this.dictionary,
    this.key,
  }) : super(db);

  Future<Challenge?> getCurrent(int level) async {
    List<Challenge> matches = items.values.where((e) => e.level == level).toList();
    matches.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (matches.isNotEmpty && !matches.first.finished) {
      return matches.first;
    }

    final c = await db.getCurrentChallenge(level);
    if (c.ok) return c.object!;
    if (isAuthority) return create(level);
    return null;
  }

  Challenge create(int level) {
    int _today = today().millisecondsSinceEpoch;
    final config = Challenges.config(level);
    String word = dictionary.randomWord(config.wordLength, seed: _today % (key ?? defaultChallengeKey));
    Challenge c = Challenge(
      level: level,
      timestamp: _today,
      endTime: _today + Challenges.duration(level),
      answer: word,
    );
    write(c);
    return c;
  }
}
