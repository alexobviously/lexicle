import 'dart:math';
import 'package:common/common.dart';

const double ratingCentre = 1500;
const double dFactor = 350;
const double kFactor = 84;
const double dRate = 10;
const double minD = 50;

double expectedScore(double a, double b) {
  final ratio = (b - a) / dFactor;
  return 1 / (1 + pow(10, ratio));
}

double realScore(num a, num b) {
  if (a.round() == b.round()) return 0.5;
  return a < b ? 1.0 : 0.0; // remember: less is better
}

double degradeDeviation(double rd) => max(rd - (dFactor / dRate), minD);

Map<String, Rating> adjustRatings(List<PlayerResult> results) {
  final newRatings = <String, Rating>{};
  final ratings = results.map((e) => e.rating.rating).toList();
  final k = results
      .map((e) => kFactor * (e.rating.deviation / dFactor))
      .toList();
  for (int i = 0; i < results.length; i++) {
    for (int j = i + 1; j < results.length; j++) {
      if (i == j) continue;
      final e = expectedScore(
        results[i].rating.rating,
        results[j].rating.rating,
      );
      final s = realScore(results[i].score, results[j].score);
      ratings[i] = ratings[i] + k[i] * (s - e);
      ratings[j] = ratings[j] + k[j] * -(s - e);
    }
    newRatings[results[i].id] = Rating(
      ratings[i],
      degradeDeviation(results[i].rating.deviation),
    );
  }

  return newRatings;
}

class PlayerResult {
  final String id;
  final Rating rating;
  final num score;
  PlayerResult({required this.id, required this.rating, required this.score});

  PlayerResult copyWith({String? id, Rating? rating, num? score}) =>
      PlayerResult(
        id: id ?? this.id,
        rating: rating ?? this.rating,
        score: score ?? this.score,
      );

  @override
  String toString() => 'PlayerResult($id, $rating, $score)';
}
