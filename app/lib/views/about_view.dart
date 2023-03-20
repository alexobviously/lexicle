import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word_game/cubits/server_cubit.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool dark = theme.brightness == Brightness.dark;
    return StandardScaffold(
      title: 'About Lexicle',
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lexicle is a multiplayer word guessing game, inspired by Wordle.',
                    style: textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 32),
                  Text(
                    'It is free, open source, and licensed under the GPL. You can find the code on Github; contributions are welcome and you can generally do what you want with it.',
                    style: textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  OutlinedButton.icon(
                    onPressed: () => launch('https://github.com/alexobviously/lexicle'),
                    icon: Image.asset('assets/images/github_${dark ? 'white' : 'black'}.png'),
                    label: Text(
                      'View Code on Github',
                      style: textTheme.headline6,
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () => _showDebugDialog(context),
                    child: SizedBox(
                      width: 64,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Code etc', style: textTheme.headline6),
                          Text('Alex Baker'),
                          Text('Steve Beville'),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Good Pals', style: textTheme.headline6),
                          Text('Gary & Gril'),
                          Text('Franc'),
                          Text('Evan'),
                          Text('Bryce'),
                          Text('Cal'),
                          Text('Blaž'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                      maxHeight: 150,
                    ),
                    child: Image.asset('assets/images/gpg_logo.png'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDebugDialog(BuildContext context) {
    final meta = BlocProvider.of<ServerCubit>(context).state;
    Row _row(String left, String right) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left),
            SizedBox(width: 32),
            Text(
              right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Server name', meta.serverName),
              _row('Server version', meta.serverVersion),
              _row('App min version', meta.appMinVersion),
              _row('App current version', meta.appCurrentVersion),
            ],
          ),
        );
      },
    );
  }
}
