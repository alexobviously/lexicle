import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    setState(() {
      nameController.text = BlocProvider.of<GameGroupManager>(context).player;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<GameGroupManager>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return StandardScaffold(
      title: 'Online Play',
      body: Center(
        child: SafeArea(
          child: BlocBuilder<GameGroupManager, GroupManagerState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                          ),
                        ),
                        NeumorphicButton(
                          onPressed: () => cubit.setPlayer(nameController.text),
                          child: const Icon(MdiIcons.keyboardReturn),
                        ),
                        Container(width: 10),
                        NeumorphicButton(
                          onPressed: () => cubit.refresh(),
                          child: const Icon(MdiIcons.refresh),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.groups.length,
                    itemBuilder: (context, i) {
                      GameGroup g = state.groups.entries.toList()[i].value;
                      Color? tileColour = i % 2 == 0 ? Colours.wrong : null;
                      bool joined = state.joined.contains(g.id);
                      if (joined) tileColour = Colours.semiCorrect;
                      return ListTile(
                        title: Text(g.title),
                        tileColor: tileColour,
                        leading: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${g.players.length}', style: textTheme.headline5, textAlign: TextAlign.center),
                        ),
                        trailing: NeumorphicButton(
                          style: NeumorphicStyle(
                            color: tileColour,
                            depth: 2,
                          ),
                          onPressed: () => joined ? cubit.leaveGroup(g.id) : cubit.joinGroup(g.id),
                          child: SizedBox(
                            width: 50,
                            child: Text(
                              joined ? 'Leave' : 'Join',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
