import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:word_game/main.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return StandardScaffold(
      title: 'Settings',
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Spacer(),
                  Expanded(
                    child: Text('Dark Mode:', style: textTheme.headline6),
                  ),
                  IconButton(
                      onPressed: () {
                        MyApp.themeNotifier.value =
                            MyApp.themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                      },
                      icon: Icon(MyApp.themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode)),
                  Spacer(),
                ],
              ),
              Spacer(),
              _version(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _version() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Version ${snapshot.data!.version}'),
              ),
            ],
          );
        } else {
          return Text('Version...');
        }
      },
    );
  }
}
