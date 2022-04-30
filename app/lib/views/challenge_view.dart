import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/challenge_manager.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/views/game_view.dart';

class ChallengeView extends StatefulWidget {
  final String? id;
  final int? level;
  final int? sequence;
  const ChallengeView({this.id, this.level, this.sequence, Key? key})
      : assert(id != null || level != null, 'Provide at least a level or an ID.'),
        super(key: key);

  @override
  State<ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends State<ChallengeView> {
  late Future<Result<Challenge>> future;

  @override
  void initState() {
    final cubit = BlocProvider.of<ChallengeManager>(context);
    future = cubit.getChallenge(
      id: widget.id,
      level: widget.level,
      sequence: widget.sequence,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Challenge>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _loading();
        if (!snapshot.hasData) return _error(null);
        Result<Challenge> result = snapshot.data!;
        if (!result.ok) return _error(result.error!);
        Challenge challenge = result.object!;
        return BlocBuilder<ChallengeManager, ChallengeManagerState>(
          builder: (context, state) {
            if (!state.hasAttempt(challenge.id)) return _loading();
            BaseGameController gc = state.games[challenge.id]!;
            return GameView(
              id: gc.state.id,
              data: GameRouteData(
                game: gc,
                title: challenge.title,
              ),
            );
          },
        );
      },
    );
  }

  Widget _loading() => StandardScaffold(
        body: SafeArea(
          child: Center(
            child: SpinKitCircle(
              color: ColourScheme.base(context).correct,
            ),
          ),
        ),
      );

  Widget _error(String? error) => StandardScaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error),
                Text(error ?? 'error'),
              ],
            ),
          ),
        ),
      );
}
