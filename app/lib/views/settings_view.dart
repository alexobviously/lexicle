import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/cubits/settings_cubit.dart';
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
    final cubit = BlocProvider.of<SettingsCubit>(context);

    return StandardScaffold(
      title: 'Settings',
      body: Center(
        child: SafeArea(
          child: BlocBuilder<SettingsCubit, Settings>(builder: (context, settings) {
            final _themeModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
            return Column(
              children: [
                Spacer(),
                Text('Theme Mode', style: textTheme.headline6),
                ToggleButtons(
                  children: _themeModes.map((e) => _themeModeBox(context, e)).toList(),
                  isSelected: _themeModes.map((e) => e == settings.themeMode).toList(),
                  onPressed: (i) => cubit.setThemeMode(_themeModes[i]),
                ),
                Container(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Spacer(),
                //     Expanded(
                //       child: Text('Dark Mode:', style: textTheme.headline6),
                //     ),
                //     IconButton(
                //       onPressed: () {
                //         MyApp.themeNotifier.value =
                //             MyApp.themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                //       },
                //       icon: Icon(MyApp.themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                //     ),
                //     Spacer(),
                //   ],
                // ),
                Text('Colour Scheme', style: textTheme.headline6),
                BlocBuilder<SchemeCubit, ColourScheme>(
                  builder: (context, scheme) {
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
            );
          }),
        ),
      ),
    );
  }

  Widget _themeModeBox(BuildContext context, ThemeMode mode) {
    final _icons = {
      ThemeMode.light: Icons.light_mode,
      ThemeMode.dark: Icons.dark_mode,
      ThemeMode.system: MdiIcons.tuneVertical
    };
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // decoration: BoxDecoration(
        //   border: Border.all(width: 1.0, color: Colors.white38),
        // ),
        width: 66,
        child: Column(
          children: [
            Icon(_icons[mode]!),
            Text(mode.name),
          ],
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
        // decoration: BoxDecoration(
        //   border: Border.all(width: 1.0, color: Colors.white38),
        // ),
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
