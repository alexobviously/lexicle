import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/services/service_locator.dart';

class GameGroupManager extends Cubit<GroupManagerState> {
  String get player => auth().state.name;
  GameGroupManager() : super(GroupManagerState.initial()) {
    init();
  }

  late Timer timer;

  void init() {
    auth().stream.listen(_handleAuthState);
    timer = Timer.periodic(Duration(milliseconds: 5000), _onTimerEvent);
  }

  void _onTimerEvent(Timer t) {
    print('on timer event');
    refresh();
  }

  @override
  Future<void> close() {
    timer.cancel();
    return super.close();
  }

  void _handleAuthState(AuthState authState) {
    refresh();
  }

  void refresh() async {
    emit(state.copyWith(working: true));
    print('refreshing groups');
    final _result = await ApiClient.allGroups();
    print('groups: $_result');
    if (!_result.ok || isClosed) return;
    final groupList = _result.object!;
    for (final g in groupList) {
      getGroup(g);
    }
    emit(state.copyWith(working: false));
  }

  void updateGroup(GameGroup g) {
    List<String> joined = List.from(state.joined);
    if (g.players.contains(player) && !joined.contains(g.id)) {
      joined.add(g.id);
    } else if (!g.players.contains(player) && joined.contains(g.id)) {
      joined.remove(g.id);
    }
    if (isClosed) return;
    emit(state.copyWith(groups: Map.from(state.groups)..[g.id] = g, joined: joined));
  }

  Future<Result<GameGroup>> getGroup(String id) async {
    final _result = await ApiClient.getGroup(id);
    if (!_result.ok) return Result.error(_result.error!);
    GameGroup g = _result.object!;
    updateGroup(g);
    return Result.ok(g);
  }

  void joinGroup(String id) async {
    final _result = await ApiClient.joinGroup(id, player);
    if (!_result.ok) return;
    GameGroup g = _result.object!;
    updateGroup(g);
  }

  void leaveGroup(String id) async {
    final _result = await ApiClient.leaveGroup(id, player);
    if (!_result.ok) return;
    GameGroup g = _result.object!;
    print(g.players);
    updateGroup(g);
  }

  void deleteGroup(String id) async {
    final _result = await ApiClient.deleteGroup(id, player);
    if (!_result.ok) return;
    emit(state.copyWith(
      groups: Map.from(state.groups)..remove(id),
      joined: List.from(state.joined)..remove(id),
    ));
  }

  void createGroup(GameConfig config) async {
    final _result = await ApiClient.createGroup(player, config);
    if (!_result.ok) return;
    updateGroup(_result.object!);
  }
}

class GroupManagerState {
  final Map<String, GameGroup> groups;
  final List<String> joined;
  final bool working;

  GroupManagerState({
    this.groups = const {},
    this.joined = const [],
    this.working = false,
  });
  factory GroupManagerState.initial() => GroupManagerState();

  GroupManagerState copyWith({
    Map<String, GameGroup>? groups,
    List<String>? joined,
    bool? working,
  }) =>
      GroupManagerState(
        groups: groups ?? this.groups,
        joined: joined ?? this.joined,
        working: working ?? this.working,
      );
}
