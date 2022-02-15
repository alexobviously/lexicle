import 'package:bloc/bloc.dart';
import 'package:common/common.dart';

abstract class BaseGameController implements Cubit<Game> {
  bool get canAct;

  Future<bool> enter();
  void backspace();
  void addLetter(String l);
  void clearInput();

  Stream<int> get numRowsStream;
  Stream<bool> get gameFinishedStream;
}
