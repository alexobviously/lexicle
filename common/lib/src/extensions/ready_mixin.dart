enum ReadyState {
  initial,
  loading,
  ready,
}

mixin ReadyManager {
  ReadyState _state = ReadyState.initial;
  Future<bool> get ready async {
    while (true) {
      if (_state == ReadyState.ready) return true;
      if (_state == ReadyState.initial) {
        _state = ReadyState.loading;
        init();
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void setReady() => _state = ReadyState.ready;
  void setLoading() => _state = ReadyState.loading;
  void setReadyState([ReadyState r = ReadyState.ready]) => _state = r;

  void init() {
    _state = ReadyState.loading;
    initialise();
  }

  void initialise();
}
