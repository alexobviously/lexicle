import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/cubits/settings_cubit.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

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
          child: BlocBuilder<SettingsCubit, Settings>(
            builder: (context, settings) {
              final themeModes = [
                ThemeMode.light,
                ThemeMode.dark,
                ThemeMode.system,
              ];
              return Column(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.push(Routes.changePassword),
                    child: const Text('Change Password'),
                  ),
                  Container(height: 32),
                  Text('Theme Mode', style: textTheme.titleLarge),
                  ToggleButtons(
                    isSelected: themeModes
                        .map((e) => e == settings.themeMode)
                        .toList(),
                    onPressed: (i) => cubit.setThemeMode(themeModes[i]),
                    children: themeModes
                        .map((e) => _themeModeBox(context, e))
                        .toList(),
                  ),
                  Container(height: 16),
                  Text('Colour Scheme', style: textTheme.titleLarge),
                  BlocBuilder<SchemeCubit, ColourScheme>(
                    builder: (context, scheme) {
                      return ToggleButtons(
                        isSelected: ColourSchemePair.all
                            .map<bool>(
                              (e) => [e.light, e.dark].contains(scheme),
                            )
                            .toList(),
                        onPressed: (i) =>
                            cubit.setScheme(ColourSchemePair.all[i]),
                        children: ColourSchemePair.all
                            .map((e) => _schemeBox(context, e))
                            .toList(),
                      );
                    },
                  ),
                  const Spacer(),
                  _version(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _themeModeBox(BuildContext context, ThemeMode mode) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        // decoration: BoxDecoration(
        //   border: Border.all(width: 1.0, color: Colors.white38),
        // ),
        width: 66,
        child: Column(
          children: [
            Icon(switch (mode) {
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
              ThemeMode.system => MdiIcons.tuneVertical,
            }),
            Text(mode.name),
          ],
        ),
      ),
    );
  }

  Widget _schemeBox(BuildContext context, ColourSchemePair scheme) {
    Widget box(Color c) => Container(
      width: 32,
      height: 32,
      color: c,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        // decoration: BoxDecoration(
        //   border: Border.all(width: 1.0, color: Colors.white38),
        // ),
        width: 66,
        height: 66,
        child: Column(
          children: [
            Row(
              children: [
                box(scheme.light.correct),
                box(scheme.light.semiCorrect),
              ],
            ),
            Row(
              children: [
                box(scheme.dark.correct),
                box(scheme.dark.semiCorrect),
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
          return const Text('Version...');
        }
      },
    );
  }
}
