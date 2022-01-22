import 'package:flutter/material.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      title: 'Settings',
      body: Center(
        child: SafeArea(
          child: Column(
            children: const [
              Text('nothing here yet'),
            ],
          ),
        ),
      ),
    );
  }
}
