import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/entity_future_builder.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class TeamView extends StatefulWidget {
  final String id;
  const TeamView(this.id, {Key? key}) : super(key: key);

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  late Future<Result<Team>> future;
  int? members;

  @override
  void initState() {
    future = teamStore().get(widget.id);
    super.initState();
  }

  void _refresh([bool canPop = false]) {
    if (canPop && members != null && members == 1) {
      context.pop();
    } else if (mounted) {
      setState(() {
        future = teamStore().get(widget.id, true);
      });
    }
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _join() async {
    final result = await auth().joinTeam(widget.id);
    if (result.ok) {
      _refresh();
      _showSnackbar('Joined successfully!');
    } else {
      _showSnackbar('Error: ${result.error!}');
    }
  }

  void _leave() async {
    final result = await auth().leaveTeam();
    if (result.ok) {
      _refresh(true);
      _showSnackbar('Left successfully!');
    } else {
      _showSnackbar('Error: ${result.error!}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return StandardScaffold(
      title: 'Team Details',
      body: SafeArea(
        child: EntityFutureBuilder<Team>(
          key: UniqueKey(),
          future: future,
          loadingWidget: Center(child: SpinKitCubeGrid(color: Colours.victory, size: 64)),
          errorWidget: (_) => Icon(Icons.error),
          resultWidget: (team) {
            members = team.members.length; // kinda messy but whatever
            return Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        team.name,
                        style: textTheme.headline4,
                      ),
                    ),
                    BlocBuilder<AuthController, AuthState>(builder: (context, state) {
                      if (state.loggedIn && state.user!.team != null && state.user!.team != team.id) return Container();
                      bool joined = state.loggedIn && state.user!.team == team.id;
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          child: NeumorphicButton(
                            style: NeumorphicStyle(depth: 2),
                            child: Text(joined ? 'Leave' : 'Join'),
                            onPressed: joined ? _leave : _join,
                          ),
                        ),
                      );
                    })
                  ],
                ),
                Container(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Members', style: textTheme.headline5),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${team.members.length}', style: textTheme.headline6),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: team.members.length,
                    itemBuilder: (context, i) {
                      return EntityFutureBuilder<User>(
                        id: team.members[i],
                        store: userStore(),
                        loadingWidget: SpinKitCircle(size: 16, color: Colours.victory),
                        errorWidget: (_) => Icon(Icons.error),
                        resultWidget: (user) => InkWell(
                          onTap: () => context.push(Routes.user(user.id)),
                          child: Container(
                            color: _rowColour(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                children: [
                                  Text(user.username, style: textTheme.headline5),
                                  Spacer(),
                                  Text(user.rating.rating.toStringAsFixed(0), style: textTheme.headline5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color? _rowColour(int i) {
    if (i == 0) return Colours.gold.lighten();
    return i % 2 == 0 ? Colours.wrong : null;
  }
}
