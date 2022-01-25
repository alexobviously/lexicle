import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:word_game/services/api_client.dart';

class GameGroupManager extends Cubit<GroupManagerState> {
  String player = 'player${Random().nextInt(1000)}'; // shouldn't rly be here
  GameGroupManager() : super(GroupManagerState.initial());

  void setPlayer(String p) {
    player = p;
    refresh();
  }

  void refresh() async {
    print('refreshing groups');
    final _result = await ApiClient.allGroups();
    print('groups: $_result');
    if (!_result.ok) return;
    final groupList = _result.object!;
    for (final g in groupList) {
      getGroup(g);
    }
  }

  void updateGroup(GameGroup g) {
    List<String> joined = List.from(state.joined);
    if (g.players.contains(player) && !joined.contains(g.id)) {
      joined.add(g.id);
    } else if (!g.players.contains(player) && joined.contains(g.id)) {
      joined.remove(g.id);
    }
    emit(state.copyWith(groups: Map.from(state.groups)..[g.id] = g, joined: joined));
  }

  void getGroup(String id) async {
    final _result = await ApiClient.getGroup(id);
    if (!_result.ok) return;
    GameGroup g = _result.object!;
    updateGroup(g);
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
}

class GroupManagerState {
  final Map<String, GameGroup> groups;
  final List<String> joined;

  GroupManagerState({this.groups = const {}, this.joined = const []});
  factory GroupManagerState.initial() => GroupManagerState();

  GroupManagerState copyWith({
    Map<String, GameGroup>? groups,
    List<String>? joined,
  }) =>
      GroupManagerState(
        groups: groups ?? this.groups,
        joined: joined ?? this.joined,
      );
}
