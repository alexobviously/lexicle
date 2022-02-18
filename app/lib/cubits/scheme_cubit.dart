import 'package:bloc/bloc.dart';
import 'package:word_game/app/colours.dart';

class SchemeCubit extends Cubit<ColourScheme> {
  SchemeCubit() : super(ColourScheme.light) {
    init();
  }

  bool dark = false;
  ColourSchemePair scheme = ColourSchemePair.normal;

  void init() {
    // warning steve might touch this
    // todo: load stuff from preferences
  }

  void _emit() {
    emit(dark ? scheme.dark : scheme.light);
  }

  void setDark(bool d) {
    if (d == dark) return;
    dark = d;
    _emit();
  }

  void setScheme(ColourSchemePair s) {
    if (scheme == s) return;
    scheme = s;
    _emit();
  }
}
