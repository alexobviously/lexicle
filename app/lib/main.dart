import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/app/themes.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/cubits/challenge_manager.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/cubits/local_game_manager.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/cubits/server_meta_cubit.dart';
import 'package:word_game/cubits/settings_cubit.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/services/api_service.dart';
import 'package:word_game/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await loadEnv();
  await setUpServiceLocator(db: ApiService());
  await dictionary().ready;
  await sound().ready;
  runApp(MyApp());
}

Future<void> loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    if (dotenv.env['SERVER_HOST'] != null) ApiClient.host = dotenv.env['SERVER_HOST']!;
  } catch (_) {
    print('.env not loaded, no problem tho');
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _appKey = GlobalKey();
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final _settingsCubit = SettingsCubit();
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthController>(
          create: (_) => auth(),
        ),
        BlocProvider<LocalGameManager>(
          create: (_) => LocalGameManager(),
        ),
        BlocProvider<GameGroupManager>(
          create: (_) => GameGroupManager(),
        ),
        BlocProvider<ServerMetaCubit>(
          create: (_) => ServerMetaCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => _settingsCubit,
          lazy: false,
        ),
        BlocProvider<SchemeCubit>(
          create: (_) => SchemeCubit(settingsCubit: _settingsCubit),
          lazy: false,
        ),
        BlocProvider<ChallengeManager>(
          create: (_) => ChallengeManager(),
          lazy: true,
        ),
      ],
      child: BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
        return NeumorphicTheme(
          theme: neumorphicLight,
          darkTheme: neumorphicDark,
          themeMode: settings.themeMode,
          child: FlutterWebFrame(
            builder: (context) {
              return MaterialApp.router(
                key: _appKey,
                title: 'Lexicle',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: settings.themeMode,
                debugShowCheckedModeBanner: false,
                routeInformationParser: _router.routeInformationParser,
                routerDelegate: _router.routerDelegate,
              );
            },
            maximumSize: Size(475.0, 812.0),
            enabled: kIsWeb,
            backgroundColor: settings.colourScheme.wrong,
          ),
        );
      }),
    );
  }
}
