import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/ui/result_future_builder.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class TopPlayersView extends StatefulWidget {
  const TopPlayersView({super.key});

  @override
  State<TopPlayersView> createState() => _TopPlayersViewState();
}

class _TopPlayersViewState extends State<TopPlayersView> {
  TextEditingController nameController = TextEditingController();

  Color? _rowColour(int i, ColourScheme scheme) {
    if (i == 0) return scheme.gold;
    if (i == 1) return scheme.silver;
    if (i == 2) return scheme.bronze;
    return i % 2 == 0 ? scheme.alt : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return StandardScaffold(
      title: 'Rankings',
      body: Center(
        child: SafeArea(
          child: BlocBuilder<SchemeCubit, ColourScheme>(builder: (context, scheme) {
            return Column(
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
                              color: _rowColour(i, scheme),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 50, child: Text('${i + 1}', style: textTheme.headlineMedium)),
                                    Text(u.username, style: textTheme.headlineMedium),
                                    Spacer(),
                                    Text(u.rating.rating.toStringAsFixed(0), style: textTheme.headlineMedium),
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
            );
          }),
        ),
      ),
    );
  }
}
