import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/services/app_dictionary.dart';
import 'package:word_game/services/environment.dart';

GetIt getIt = GetIt.I;

AppDictionary dictionary() => getIt.get<AppDictionary>();
AuthController auth() => getIt.get<AuthController>();
Environment env() => getIt.get<Environment>();
FlutterSecureStorage storage() => getIt.get<FlutterSecureStorage>();

Future<void> setUpServiceLocator({required Environment environment}) async {
  getIt.registerSingleton<AppDictionary>(AppDictionary());
  getIt.registerSingleton<AuthController>(AuthController());
  getIt.registerSingleton<Environment>(environment);
  getIt.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
}
