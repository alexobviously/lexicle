import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/services/service_locator.dart';

class ObserverGameController extends Cubit<Game> implements BaseGameController {
  final Duration updateInterval;
  ObserverGameController(Game initialState, {this.updateInterval = const Duration(seconds: 5)}) : super(initialState) {
    _init();
  }

  Timer? _timer;

  void _init() {
    _update();
  }

  void _update() async {
    final result = await gameStore().get(state.id, true);
    if (isClosed) return;
    if (result.ok) {
      emit(result.object!);
    }
    if (!result.ok || !result.object!.gameFinished) {
      _timer = Timer(updateInterval, _update);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  @override
  bool get canAct => false;

  @override
  void backspace() {}
  @override
  Future<bool> enter() async => false;
  @override
  void addLetter(String l) {}
  @override
  void clearInput() {}

  @override
  Stream<int> get numRowsStream => stream.map((e) => e.numRows).distinct();
  @override
  Stream<bool> get gameFinishedStream => stream.map((e) => e.gameFinished).distinct();
}
