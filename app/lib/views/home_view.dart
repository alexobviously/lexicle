import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/ui/standard_scaffold.dart';

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
    return StandardScaffold(
      showBackButton: false,
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
              NeumorphicButton(
                onPressed: () => Navigator.of(context).pushNamed('/solo'),
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                ),
                child: Text('Play Offline', style: textTheme.headline6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
