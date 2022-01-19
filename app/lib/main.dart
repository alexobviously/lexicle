import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_game/cubits/game_manager.dart';
import 'package:word_game/home_view.dart';
import 'package:word_game/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServiceLocator();
  await dictionary().ready;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameManager>(
          create: (_) => GameManager(),
        ),
      ],
      child: MaterialApp(
        title: 'Word Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.grey.shade300,
          fontFamily: GoogleFonts.dmSans().fontFamily,
          dividerColor: Colors.grey.shade400,
        ),
        home: const HomeView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
