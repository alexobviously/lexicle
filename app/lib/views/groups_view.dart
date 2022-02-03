import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/game_creator.dart';
import 'package:word_game/ui/neumorphic_text_field.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/views/group_view.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
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
                          child: NeumorphicTextField(
                            controller: nameController,
                            enabled: state.joined.isEmpty,
                            onClear: state.joined.isEmpty && auth().state.name.isNotEmpty
                                ? () {
                                    auth().setName('');
                                    setState(() => nameController.text = '');
                                  }
                                : null,
                          ),
                          // child: Neumorphic(
                          //   style: NeumorphicStyle(
                          //     depth: -2,
                          //   ),
                          //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                          //   child: TextField(
                          //     enabled: state.joined.isEmpty,
                          //     controller: nameController,
                          //     decoration: InputDecoration(
                          //       suffixIcon: state.joined.isEmpty && auth().state.name.isNotEmpty
                          //           ? IconButton(
                          //               onPressed: () {
                          //                 auth().setName('');
                          //                 setState(() => nameController.text = '');
                          //               },
                          //               icon: Icon(Icons.clear),
                          //             )
                          //           : null,
                          //     ),
                          //   ),
                          // ),
                        ),
                        NeumorphicButton(
                          onPressed: state.joined.isEmpty ? () => auth().setName(nameController.text) : null,
                          child: const Icon(MdiIcons.keyboardReturn),
                        ),
                        Container(width: 10),
                        NeumorphicButton(
                          onPressed: () => state.working ? null : cubit.refresh(),
                          child: state.working
                              ? SpinKitFadingCircle(size: 24, color: Colors.black87)
                              : const Icon(MdiIcons.refresh),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 20),
                  Expanded(
                    child: ListView.builder(
                      // shrinkWrap: true,
                      itemCount: state.groups.length,
                      itemBuilder: (context, i) {
                        GameGroup g = state.groups.entries.toList().reversed.toList()[i].value;
                        bool isCreator = g.creator == auth().state.name;
                        Color? tileColour = i % 2 == 0 ? Colours.wrong : null;
                        bool joined = state.joined.contains(g.id);
                        if (joined) tileColour = Colours.semiCorrect;
                        if (g.finished) tileColour = Colours.victory;
                        return ListTile(
                          title: Text(g.title),
                          tileColor: tileColour,
                          onTap: joined
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => GroupView(cubit.getControllerForGroup(g)),
                                    ),
                                  )
                              : null,
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${g.players.length}', style: textTheme.headline5, textAlign: TextAlign.center),
                          ),
                          trailing: !g.started && auth().state.name.isNotEmpty
                              ? NeumorphicButton(
                                  style: NeumorphicStyle(
                                    color: tileColour,
                                    depth: 2,
                                  ),
                                  onPressed: () {
                                    if (isCreator) {
                                      cubit.deleteGroup(g.id);
                                    } else if (joined) {
                                      cubit.leaveGroup(g.id);
                                    } else {
                                      cubit.joinGroup(g.id);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    child: Text(
                                      isCreator
                                          ? 'Delete'
                                          : joined
                                              ? 'Leave'
                                              : 'Join',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                  GameCreator(
                    showTitle: true,
                    onCreate: (cfg) => cubit.createGroup(cfg.title, cfg.config),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
