import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../server.dart';
import '../services/mongo_service.dart';
import '../services/service_locator.dart';

void main(List<String> args) async {
  print('Reading .env...');
  final env = readEnvironment();
  print('Connecting to MongoDB...');
  final db = MongoService();
  await db.init(env);
  print('MongoDB ready!');
  await setUpServiceLocator(environment: env, db: db);

  final bob = (await userStore().getByUsername('bob')).object!;
  final tester = (await userStore().getByUsername('tester')).object!;
  final bakr = (await userStore().getByUsername('bakr')).object!;

  final groups = await db.getAll<GameGroup>(
    selector: where.oneFrom(GroupFields.players, [bob.id, tester.id, bakr.id]),
  );
  print('Groups found: ${groups.length}');

  for (GameGroup g in groups) {
    final games = await db.getAll<Game>(
      selector: where.eq(GameFields.group, g.id),
    );
    print('Group ${g.title} has ${games.length} games');
    db.db.collection('games').deleteMany(where.eq(GameFields.group, g.id));
    db.delete<GameGroup>(g);
  }
}
