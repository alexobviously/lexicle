import 'package:common/common.dart';
import 'package:common/src/utils/rating_utils.dart';

class Rating {
  final double rating;
  final double deviation;
  Rating(this.rating, this.deviation);
  factory Rating.initial() => Rating(ratingCentre, dFactor);

  factory Rating.fromJson(Map<String, dynamic> doc) {
    return Rating(doc[UserFields.rating], doc[UserFields.deviation]);
  }

  Map<String, dynamic> toMap() => {UserFields.rating: rating, UserFields.deviation: deviation};

  @override
  String toString() => 'Rating(${rating.toStringAsFixed(1)}, ${deviation.toStringAsFixed(1)})';
}
