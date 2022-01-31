import 'package:common/common.dart';

class GameStore extends EntityStore<Game> {
  GameStore(DatabaseService db) : super(db);
}
