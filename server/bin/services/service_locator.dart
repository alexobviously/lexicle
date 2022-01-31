import 'package:common/common.dart';
import 'package:get_it/get_it.dart';
import '../gameserver/game_server.dart';
import 'dictionary.dart';
import 'environment.dart';

GetIt getIt = GetIt.I;

ServerDictionary dictionary() => getIt.get<ServerDictionary>();
GameServer gameServer() => getIt.get<GameServer>();
Environment env() => getIt.get<Environment>();
DatabaseService db() => getIt.get<DatabaseService>();
GameStore gameStore() => getIt.get<GameStore>();
GameGroupStore groupStore() => getIt.get<GameGroupStore>();

Future<void> setUpServiceLocator({required Environment environment, required DatabaseService db}) async {
  getIt.registerSingleton<ServerDictionary>(ServerDictionary());
  getIt.registerSingleton<GameServer>(GameServer());
  getIt.registerSingleton<Environment>(environment);
  getIt.registerSingleton<DatabaseService>(db);
  getIt.registerSingleton<GameStore>(GameStore(db));
  getIt.registerSingleton<GameGroupStore>(GameGroupStore(db));
}
