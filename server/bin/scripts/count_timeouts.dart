// absolutely do not run this again pls

// import 'package:common/common.dart';
// import 'package:mongo_dart/mongo_dart.dart';

// import '../server.dart';
// import '../services/mongo_service.dart';
// import '../services/service_locator.dart';

// void main(List<String> args) async {
  // print('Reading .env...');
  // final env = readEnvironment();
  // print('Connecting to MongoDB...');
  // final _db = MongoService();
  // await _db.init(env);
  // print('MongoDB ready!');
  // await setUpServiceLocator(environment: env, db: _db);

//   final games = await _db.getAll<Game>(selector: where.eq(GameFields.endReason, EndReasons.timeout));
//   print(games.length);
//   Set<String> userIds = games.map((e) => e.player).toSet();
//   print(userIds);
//   print(userIds.length);
//   await ustatsStore().getMultiple(userIds.toList());
//   for (Game g in games) {
//     final result = await ustatsStore().get(g.player);
//     if (result.ok) {
//       UserStats u = result.object!;
//       Map<int, int> timeouts = u.timeouts;
//       timeouts[g.length] = (timeouts[g.length] ?? 0) + 1;
//       u = u.copyWith(timeouts: timeouts);
//       await ustatsStore().set(u);
//     }
//   }
//   final ustats = await ustatsStore().getMultiple(userIds.toList());
//   for (final u in ustats) {
//     print('u: ${u.id}');
//     print('---- ${u.timeouts}');
//   }
//   ustatsStore().pushCache();
// }
