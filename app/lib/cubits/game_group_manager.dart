import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/cubits/game_group_controller.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/services/service_locator.dart';

class GameGroupManager extends Cubit<GroupManagerState> {
  Map<String, GameGroupController> groupControllers = {};
  Map<String, StreamSubscription> streams = {};
  String? get player => auth().userId;
  GameGroupManager() : super(GroupManagerState.initial()) {
    init();
  }

  late Timer timer;

  bool hasController(String id) => groupControllers.containsKey(id);
  GameGroupController? getControllerForId(String id) => groupControllers[id];
  GameGroupController getControllerForGroup(GameGroup g) {
    if (groupControllers.containsKey(g.id)) {
      return groupControllers[g.id]!;
    }
    final ggc = GameGroupController(GameGroupState(group: g));
    groupControllers[g.id] = ggc;
    _listenToGroupController(ggc);
    return ggc;
  }

  void init() {
    auth().stream.listen(_handleAuthState);
    timer = Timer.periodic(Duration(milliseconds: 5000), _onTimerEvent);
  }

  void _onTimerEvent(Timer t) {
    refresh();
  }

  @override
  Future<void> close() {
    timer.cancel();
    for (GameGroup g in state.joined) {
      if (hasController(g.id)) {
        getControllerForGroup(g).close();
      }
    }
    return super.close();
  }

  void _handleAuthState(AuthState authState) {
    refresh();
  }

  void _listenToGroupController(GameGroupController ggc) {
    _updateGroup(ggc.state.group);
    streams[ggc.id] = ggc.stream.map((e) => e.group).listen(_updateGroup);
    groupControllers[ggc.id] = ggc;
  }

  void _removeController(String id) {
    streams[id]?.cancel();
    streams.remove(id);
    groupControllers.remove(id);
  }

  void _processJoinedGroups(List<GameGroup> groups) {
    for (GameGroup g in groups) {
      if (hasController(g.id)) {
        getControllerForGroup(g).update(g);
      } else {
        getGroup(g.id);
      }
    }
  }

  void refresh() async {
    emit(state.copyWith(working: true));
    final available = await ApiClient.availableGroups();
    if (!available.ok || isClosed) return;
    emit(state.copyWith(available: available.object!));

    final joined = await ApiClient.joinedGroups();
    if (!joined.ok || isClosed) return;
    _processJoinedGroups(joined.object!);
    emit(state.copyWith(working: false));
  }

  void _updateGroup(GameGroup g) {
    List<GameGroup> joined = [...state.joined];
    List<GameGroup> available = [...state.available];
    if (g.players.contains(player) && !state.joinedContains(g.id)) {
      joined.add(g);
      available.removeWhere((e) => e.id == g.id);
      _processJoinedGroups([g]);
    } else if (!g.players.contains(player) && state.joinedContains(g.id)) {
      joined.removeWhere((e) => e.id == g.id);
      if (!state.availableContains(g.id)) available.add(g);
      _removeController(g.id);
    }
    if (isClosed) return;
    emit(state.copyWith(joined: joined, available: available));
  }

  Future<Result<GameGroup>> getGroup(String id) async {
    final _result = await ApiClient.getGroup(id);
    if (!_result.ok) return Result.error(_result.error!);
    GameGroup g = _result.object!;
    _updateGroup(g);
    return Result.ok(g);
  }

  Future<GameGroupController?> joinGroup(String id) async {
    if (player == null) return null;
    final _result = await ApiClient.joinGroup(id, player!);
    if (!_result.ok) return null;
    GameGroup g = _result.object!;
    _updateGroup(g);
    return getControllerForGroup(g);
  }

  Future<GameGroup?> leaveGroup(String id) async {
    if (player == null) return null;
    final _result = await ApiClient.leaveGroup(id, player!);
    if (!_result.ok) return null;
    GameGroup g = _result.object!;
    _updateGroup(g);
    return g;
  }

  Future<bool> deleteGroup(String id) async {
    if (player == null) return false;
    final _result = await ApiClient.deleteGroup(id, player!);
    if (!_result.ok) return false;
    _removeController(id);
    emit(state.copyWith(joined: List.from(state.joined)..removeWhere((e) => e.id == id)));
    return true;
  }

  Future<bool> createGroup(String title, GameConfig config) async {
    if (player == null) return false;
    final _result = await ApiClient.createGroup(player!, title, config);
    if (!_result.ok) return false;
    _updateGroup(_result.object!);
    return true;
  }
}

class GroupManagerState {
  final List<GameGroup> available;
  final List<GameGroup> joined;
  final bool working;

  bool availableContains(String id) => available.where((e) => e.id == id).isNotEmpty;
  bool joinedContains(String id) => joined.where((e) => e.id == id).isNotEmpty;

  GroupManagerState({
    this.available = const [],
    this.joined = const [],
    this.working = false,
  });
  factory GroupManagerState.initial() => GroupManagerState();

  GroupManagerState copyWith({
    List<GameGroup>? available,
    List<GameGroup>? joined,
    bool? working,
  }) =>
      GroupManagerState(
        available: available ?? this.available,
        joined: joined ?? this.joined,
        working: working ?? this.working,
      );
}
