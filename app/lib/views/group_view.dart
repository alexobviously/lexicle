import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:validators/validators.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/game_group_controller.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/game_overview.dart';
import 'package:word_game/ui/game_page.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class GroupView extends StatefulWidget {
  final GameGroupController controller;
  const GroupView(this.controller, {Key? key}) : super(key: key);

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  GameGroupController get controller => widget.controller;
  TextEditingController wordController = TextEditingController();
  bool invalidWord = false;

  @override
  void initState() {
    if (controller.state.group.words.containsKey(auth().state.name)) {
      wordController.text = controller.state.group.words[auth().state.name]!;
    }
    super.initState();
  }

  void _submitWord() async {
    final state = controller.state.group;
    if (!isAlpha(wordController.text) || wordController.text.length != state.config.wordLength) return;

    final _result = await controller.setWord(wordController.text);
    if (!_result.ok) {
      setState(() => invalidWord = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      title: 'Group Game',
      body: Center(
        child: SafeArea(
          child: controller != null
              ? BlocBuilder<GameGroupController, GameGroupState>(
                  bloc: controller,
                  builder: (context, state) {
                    if (state.group.state == MatchState.lobby) {
                      return _lobbyView(context, state.group);
                    } else if (state.group.state == MatchState.playing) {
                      return _playView(context, state);
                    } else {
                      return Container();
                    }
                  },
                )
              : SpinKitFadingGrid(
                  color: Colours.correct,
                  size: 150,
                ),
        ),
      ),
    );
  }

  Widget _lobbyView(BuildContext context, GameGroup state) {
    final isCreator = auth().state.name == state.creator;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool isValid = !invalidWord && isAlpha(wordController.text);
    bool canSubmit = wordController.text.length == state.config.wordLength && isValid;
    InputBorder? wordFieldBorder = (isValid || wordController.text.isEmpty)
        ? null
        : UnderlineInputBorder(borderSide: BorderSide(color: Colours.invalid));
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Neumorphic(
            padding: EdgeInsets.all(8.0),
            style: NeumorphicStyle(
              depth: 2,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12.0)),
            ),
            child: Column(
              children: [
                Text(
                  'Set Word',
                  style: textTheme.headline5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          maxLength: state.config.wordLength,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          onChanged: (x) => setState(() => invalidWord = false), // hmm
                          textCapitalization: TextCapitalization.none,
                          controller: wordController,
                          decoration: InputDecoration(
                            border: wordFieldBorder,
                            enabledBorder: wordFieldBorder,
                            focusedBorder: wordFieldBorder,
                          ),
                        ),
                      ),
                      Container(width: 16.0),
                      NeumorphicButton(
                        onPressed: canSubmit ? _submitWord : null,
                        child: const Icon(MdiIcons.keyboardReturn),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 30),
        Text(
          'Players',
          style: textTheme.headline5,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: state.players.length,
          itemBuilder: (context, i) {
            String player = state.players[i];
            bool ready = state.playerReady(player);
            return ListTile(
              title: Text(player),
              trailing: Text(ready ? 'Ready' : 'Not Ready'),
            );
          },
        ),
        Spacer(),
        if (isCreator && state.canBegin)
          NeumorphicButton(
            onPressed: controller.start,
            child: Text(
              'Start Group',
              style: textTheme.headline5,
            ),
          ),
        if (isCreator && !state.canBegin)
          Neumorphic(
            padding: EdgeInsets.all(16.0),
            style: NeumorphicStyle(depth: 2),
            child: Text('Waiting for players..', style: textTheme.headline5),
          ),
      ],
    );
  }

  Widget _playView(BuildContext context, GameGroupState state) {
    List<GameController> gcs = state.games.entries.map((e) => e.value).toList();
    return Column(
      children: [
        GridView.count(
          // controller: _controller,
          shrinkWrap: true,
          children: gcs.reversed
              .map((e) => GestureDetector(
                    child: GameOverview(e, key: ValueKey('go_${e.state.id}')),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GamePage(game: e, title: '${e.state.creator}\'s game'),
                      ),
                    ),
                  ))
              .toList(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 4,
        ),
      ],
    );
  }
}
