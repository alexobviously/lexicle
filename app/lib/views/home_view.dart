import 'package:flutter/material.dart';
import 'package:word_game/ui/neu_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Text(
                'Counter Strike: Wordle Offensive',
                style: textTheme.headline3,
                textAlign: TextAlign.center,
              ),
              Container(height: 150),
              NeuButton(
                onPressed: () => Navigator.of(context).pushNamed('/solo'),
                child: Text('Play Offline', style: textTheme.headline5),
                elevation: 2.0,
                rounding: 25.0,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
