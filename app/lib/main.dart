import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/cubits/local_game_manager.dart';
import 'package:word_game/cubits/server_meta_cubit.dart';
import 'package:word_game/extensions/neumorphic_extensions.dart';
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
    final _theme = NeumorphicThemeData(
      baseColor: const Color(0xFFEEEEEE),
      lightSource: LightSource.topLeft,
      depth: 10,
      textTheme: GoogleFonts.dmSansTextTheme(),
      appBarTheme: appBarTheme,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
    );

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
      ],
      child: NeumorphicTheme(
        theme: _theme,
        child: Builder(
          builder: (context) => IconTheme(
            data: NeumorphicTheme.currentTheme(context).iconTheme,
            child: MaterialApp.router(
              key: _appKey,
              title: 'Lexicle',
              theme: _theme.materialTheme,
              themeMode: ThemeMode.light,
              debugShowCheckedModeBanner: false,
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
            ),
          ),
        ),
      ),
    );
  }
}

const appBarTheme = NeumorphicAppBarThemeData(
  buttonStyle: NeumorphicStyle(
    boxShape: NeumorphicBoxShape.circle(),
    depth: 2.0,
  ),
  textStyle: TextStyle(color: Colors.black54),
  iconTheme: IconThemeData(color: Colors.black54, size: 30),
);
