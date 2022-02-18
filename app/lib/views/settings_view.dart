import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
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
                    icon: Icon(MyApp.themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                  ),
                  Spacer(),
                ],
              ),
              Text('Colour Scheme', style: textTheme.headline6),
              BlocBuilder<SchemeCubit, ColourScheme>(
                builder: (context, scheme) {
                  final cubit = BlocProvider.of<SchemeCubit>(context);
                  return ToggleButtons(
                    children: ColourSchemePair.all.map((e) => _schemeBox(context, e)).toList(),
                    isSelected: ColourSchemePair.all.map<bool>((e) => [e.light, e.dark].contains(scheme)).toList(),
                    onPressed: (i) => cubit.setScheme(ColourSchemePair.all[i]),
                  );
                },
              ),
              Spacer(),
              _version(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _schemeBox(BuildContext context, ColourSchemePair scheme) {
    Widget _box(Color c) => Container(
          width: 32,
          height: 32,
          color: c,
        );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: Colors.white38),
        ),
        width: 66,
        height: 66,
        child: Column(
          children: [
            Row(
              children: [
                _box(scheme.light.correct),
                _box(scheme.light.semiCorrect),
              ],
            ),
            Row(
              children: [
                _box(scheme.dark.correct),
                _box(scheme.dark.semiCorrect),
              ],
            ),
          ],
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
