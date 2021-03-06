import 'package:common/common.dart';

class ChallengeStore extends EntityStore<Challenge> {
  final Dictionary? dictionary;
  final int? key;
  bool get isAuthority => key != null;

  ChallengeStore(
    DatabaseService db, {
    this.dictionary,
    this.key,
  })  : assert(key == null || dictionary != null, 'Dictionary must be provided if key is provided'),
        super(db);

  Future<Result<Challenge>> getBySequence(int level, int sequence) async {
    List<Challenge> matches = items.values.where((e) => e.level == level && e.sequence == sequence).toList();
    if (matches.isNotEmpty) return Result.ok(matches.first);
    final c = await db.getChallenge(level, sequence);
    if (c.ok) {
      onGet(c.object!);
      return Result.ok(c.object!);
    }
    return Result.error(c.error!);
  }

  Future<Result<Challenge>> getCurrent(int level) async {
    List<Challenge> matches = items.values.where((e) => e.level == level).toList();
    matches.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    int sequence = 0;
    if (matches.isNotEmpty) {
      if (!matches.first.finished) return Result.ok(matches.first);
    }

    final c = await db.getCurrentChallenge(level, true);
    if (c.ok) {
      onGet(c.object!);
      if (c.object!.sequence != null) sequence = c.object!.sequence! + 1;
      if (!c.object!.finished) return Result.ok(c.object!);
    }
    if (isAuthority) return Result.ok(create(level, sequence));
    return Result.error(Errors.notFound);
  }

  Challenge create(int level, int? sequence) {
    int _today = today().millisecondsSinceEpoch;
    final config = Challenges.config(level);
    String word = dictionary!.randomWord(config.wordLength, seed: _today % (key ?? defaultChallengeKey));
    Challenge c = Challenge(
      level: level,
      sequence: sequence,
      timestamp: _today,
      endTime: _today + Challenges.duration(level),
      answer: word,
    );
    write(c);
    return c;
  }
}
