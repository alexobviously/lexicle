import 'package:common/common.dart';
import 'package:get_it/get_it.dart';
import '../gameserver/game_server.dart';
import 'cache_manager.dart';
import 'dictionary.dart';
import 'environment.dart';

GetIt getIt = GetIt.I;

ServerDictionary dictionary() => getIt.get<ServerDictionary>();
GameServer gameServer() => getIt.get<GameServer>();
Environment env() => getIt.get<Environment>();
DatabaseService db() => getIt.get<DatabaseService>();
GameStore gameStore() => getIt.get<GameStore>();
GameGroupStore groupStore() => getIt.get<GameGroupStore>();
UserStore userStore() => getIt.get<UserStore>();
AuthStore authStore() => getIt.get<AuthStore>();
UserStatsStore ustatsStore() => getIt.get<UserStatsStore>();
TeamStore teamStore() => getIt.get<TeamStore>();
ChallengeStore challengeStore() => getIt.get<ChallengeStore>();
CacheManager cacheManager() => getIt.get<CacheManager>();

Future<void> setUpServiceLocator({required Environment environment, required DatabaseService db}) async {
  ServerDictionary dict = ServerDictionary();
  getIt.registerSingleton<ServerDictionary>(dict);
  getIt.registerSingleton<GameServer>(GameServer());
  getIt.registerSingleton<Environment>(environment);
  getIt.registerSingleton<DatabaseService>(db);
  getIt.registerSingleton<GameStore>(GameStore(db));
  getIt.registerSingleton<GameGroupStore>(GameGroupStore(db));
  getIt.registerSingleton<UserStore>(UserStore(db));
  getIt.registerSingleton<AuthStore>(AuthStore(db));
  getIt.registerSingleton<UserStatsStore>(UserStatsStore(db));
  getIt.registerSingleton<TeamStore>(TeamStore(db));
  getIt.registerSingleton<ChallengeStore>(ChallengeStore(db, dictionary: dict, key: 1000));
  getIt.registerSingleton<CacheManager>(CacheManager(interval: Duration(minutes: 1)));
}
