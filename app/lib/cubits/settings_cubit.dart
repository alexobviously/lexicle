import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:word_game/extensions/first_where_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_game/app/colours.dart';

class SettingsCubit extends Cubit<Settings> {
  late SharedPreferences prefs;
  final window = WidgetsBinding.instance!.window;
  Brightness get platformBrightness => window.platformBrightness;
  ThemeMode get themeMode => state.themeMode;

  SettingsCubit() : super(Settings.initial()) {
    _init();
  }

  void _init() async {
    window.onPlatformBrightnessChanged = _setBrightness;
    prefs = await SharedPreferences.getInstance();
    String tm = prefs.getString('theme_mode') ?? 'system';
    ThemeMode _themeMode = ThemeMode.values.firstWhereOrNull((e) => e.name == tm) ?? ThemeMode.system;
    setThemeMode(_themeMode, false);
    int _scheme = prefs.getInt('scheme') ?? 0;
    setScheme(ColourSchemePair.all.asMap()[_scheme] ?? ColourSchemePair.normal, false);
  }

  void _setBrightness() {
    if (themeMode == ThemeMode.system && platformBrightness != state.brightness) {
      emit(state.copyWith(brightness: platformBrightness));
    }
  }

  void setThemeMode(ThemeMode mode, [bool write = true]) {
    if (mode == themeMode) return;
    emit(state.copyWith(themeMode: mode));

    if (mode == ThemeMode.system) {
      _setBrightness();
    } else {
      Brightness b = (mode == ThemeMode.light) ? Brightness.light : Brightness.dark;
      if (b != state.brightness) {
        emit(state.copyWith(brightness: b));
      }
    }

    if (write) {
      prefs.setString('theme_mode', mode.name);
    }
  }

  void setScheme(ColourSchemePair scheme, [bool write = true]) {
    if (scheme != state.scheme) {
      emit(state.copyWith(scheme: scheme));
    }
    if (write) {
      int idx = ColourSchemePair.all.indexOf(scheme);
      if (idx == -1) return;
      prefs.setInt('scheme', idx);
    }
  }
}

class Settings {
  final ThemeMode themeMode;
  final Brightness brightness;
  final ColourSchemePair scheme;

  ColourScheme get colourScheme => scheme.ofBrightness(brightness);

  Settings({required this.themeMode, required this.brightness, required this.scheme});
  factory Settings.initial() =>
      Settings(themeMode: ThemeMode.system, brightness: Brightness.light, scheme: ColourSchemePair.normal);

  Settings copyWith({ThemeMode? themeMode, Brightness? brightness, ColourSchemePair? scheme}) => Settings(
        themeMode: themeMode ?? this.themeMode,
        brightness: brightness ?? this.brightness,
        scheme: scheme ?? this.scheme,
      );
}
