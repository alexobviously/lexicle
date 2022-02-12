import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/ui/result_future_builder.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class TopPlayersView extends StatefulWidget {
  const TopPlayersView({Key? key}) : super(key: key);

  @override
  State<TopPlayersView> createState() => _TopPlayersViewState();
}

class _TopPlayersViewState extends State<TopPlayersView> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    final cubit = BlocProvider.of<GameGroupManager>(context);
    setState(() {
      nameController.text = cubit.player;
    });
    cubit.refresh();
    super.initState();
  }

  Color? _rowColour(int i) {
    if (i == 0) return Colours.gold.lighten();
    if (i == 1) return Colours.silver;
    if (i == 2) return Colours.bronze.lighten();
    return i % 2 == 0 ? Colours.wrong : null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<GameGroupManager>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return StandardScaffold(
      title: 'Rankings',
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NeumorphicButton(
                    onPressed: () => setState(() {}),
                    child: const Icon(MdiIcons.refresh),
                  ),
                ),
              ),
              Expanded(
                child: ResultFutureBuilder<List<User>>(
                  future: ApiClient.getTopPlayers(),
                  loadingWidget: SpinKitCubeGrid(color: Colours.victory, size: 64),
                  errorWidget: (_) => Icon(Icons.error),
                  resultWidget: (users) {
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        User u = users[i];
                        return InkWell(
                          onTap: () => context.push(Routes.user(u.id)),
                          child: Container(
                            color: _rowColour(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: 50, child: Text('${i + 1}', style: textTheme.headline4)),
                                  Text(u.username, style: textTheme.headline4),
                                  Spacer(),
                                  Text(u.rating.rating.toStringAsFixed(0), style: textTheme.headline4),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
