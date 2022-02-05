import 'package:common/common.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/services/app_dictionary.dart';
import 'package:word_game/stores/app_user_store.dart';

GetIt getIt = GetIt.I;

AppDictionary dictionary() => getIt.get<AppDictionary>();
AuthController auth() => getIt.get<AuthController>();
DatabaseService db() => getIt.get<DatabaseService>();
FlutterSecureStorage storage() => getIt.get<FlutterSecureStorage>();
AppUserStore userStore() => getIt.get<AppUserStore>();

Future<void> setUpServiceLocator({required DatabaseService db}) async {
  getIt.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
  getIt.registerSingleton<DatabaseService>(db);
  getIt.registerSingleton<AppDictionary>(AppDictionary());
  getIt.registerSingleton<AuthController>(AuthController());
  getIt.registerSingleton<AppUserStore>(AppUserStore(db));
}
