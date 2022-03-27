import 'package:bloc/bloc.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/settings_cubit.dart';

/// Just listens to the SettingsCubit and updates its scheme based on it.
/// Purely for convenience in UI building.
class SchemeCubit extends Cubit<ColourScheme> {
  SchemeCubit({required SettingsCubit settingsCubit}) : super(ColourScheme.light) {
    settingsCubit.stream.listen(_onSettings);
    _onSettings(settingsCubit.state);
  }

  void _onSettings(Settings settings) {
    ColourScheme _scheme = settings.scheme.ofBrightness(settings.brightness);
    if (state != _scheme) {
      emit(_scheme);
    }
  }
}
