import 'dart:math';

import 'package:common/common.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/entity_future_builder.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class ProfileView extends StatefulWidget {
  final String id;
  const ProfileView({required this.id, Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int lengthIndex = 0;

  void setLengthIndex(int x) => setState(() => lengthIndex = x);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return StandardScaffold(
      title: 'Stats',
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EntityFutureBuilder<User>(
                id: widget.id,
                store: userStore(),
                loadingWidget: SpinKitCircle(
                  color: Colours.victory,
                  size: 64,
                ),
                errorWidget: (_) => Icon(Icons.error),
                resultWidget: (u) => Column(
                  children: [
                    Text(u.username, style: textTheme.headline4),
                    Text('Rating: ${u.rating.rating.toStringAsFixed(1)} ± ${u.rating.deviation.toStringAsFixed(0)}'),
                    if (u.team != null) _team(context, u.team!),
                  ],
                ),
              ),
              Container(height: 16),
              EntityFutureBuilder<UserStats>(
                id: widget.id,
                store: ustatsStore(),
                loadingWidget: SpinKitCircle(
                  color: Colours.victory,
                  size: 64,
                ),
                errorWidget: (_) => Icon(Icons.error),
                resultWidget: (u) {
                  if (u.gamesTotal == 0) return Text('No games played yet!');
                  int _length(int index) => u.guessCounts.keys.toList()[index];

                  return Column(
                    children: [
                      if (u.guessCounts.entries.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: NeumorphicToggle(
                            selectedIndex: lengthIndex,
                            displayForegroundOnlyIfSelected: true,
                            children: u.guessCounts.keys.map((e) => _toggleElement(context, e.toString())).toList(),
                            thumb: Neumorphic(
                              style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(12))),
                              ),
                            ),
                            onChanged: setLengthIndex,
                          ),
                        ),
                      Neumorphic(
                        padding: const EdgeInsets.all(8.0),
                        style: NeumorphicStyle(depth: -2),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                    'Matches Won: ${(u.wins[_length(lengthIndex)] ?? 0)} / ${(u.numGroups[_length(lengthIndex)] ?? 0)}'),
                                Text('Games Played: ${(u.numGames[_length(lengthIndex)] ?? 0)}'),
                              ],
                            ),
                            Text('Timeouts: ${u.timeouts[_length(lengthIndex)] ?? 0} '),
                            Container(height: 24),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: FittedBox(child: _guessChart(u.guessCounts[_length(lengthIndex)] ?? {})),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 32),
                      _words(context, u.words, scheme: ColourScheme.base(context)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ToggleElement _toggleElement(BuildContext context, String text) {
    return ToggleElement(
      foreground: Center(
          child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      background: Center(child: Text(text)),
    );
  }

  Widget _guessChart(Map<int, int> counts) {
    final textTheme = Theme.of(context).textTheme;
    final _counts = Map.from(counts);
    for (int k in counts.keys) {
      if (k > 8) {
        _counts[8] = (_counts[8] ?? 0) + counts[k];
        _counts.remove(k);
      }
    }
    int maxCount = max(1, _counts.entries.fold(0, (a, b) => max(a, b.value)));

    Color borderColour = Theme.of(context).textTheme.bodyText1?.color ?? Colors.black87;

    List<BarChartGroupData> _groups = List.generate(
        8,
        (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  y: ((_counts[i + 1] ?? 0) / maxCount) * maxCount,
                  width: 41,
                  colors: [_difficultyColour(i + 1, scheme: ColourScheme.base(context))],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2.0)),
                  borderSide: BorderSide(width: 0.3, color: borderColour.withOpacity(0.5)),
                ),
              ],
            ));

    return SizedBox(
      width: 350,
      height: 300,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (v) => '${(v + 1).toStringAsFixed(0)}${v == 7 ? '+' : ''}',
              getTextStyles: (_, __) => textTheme.headline6,
            ),
            leftTitles: SideTitles(showTitles: false),
            topTitles: SideTitles(showTitles: false),
            rightTitles: SideTitles(showTitles: false),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white,
              fitInsideVertically: true,
              getTooltipItem: (_, __, c, ___) => BarTooltipItem(c.y.toStringAsFixed(0), textTheme.bodyText2!),
            ),
          ),
          barGroups: _groups,
        ),
      ),
    );
  }

  Color _difficultyColour(double difficulty, {ColourScheme scheme = ColourScheme.light}) {
    if (difficulty < 5.5) {
      return Color.lerp(scheme.correct, scheme.semiCorrect, (difficulty - 2.0) / 3.5)!;
    } else {
      return Color.lerp(scheme.semiCorrect, scheme.invalid.lighten(0.2), (difficulty - 5.5) / 3.5)!;
    }
  }

  Widget _words(BuildContext context, List<WordDifficulty> words, {ColourScheme scheme = ColourScheme.light}) {
    final textTheme = Theme.of(context).textTheme;

    List<WordDifficulty> _words = [...words];
    _words.sort((a, b) => b.difficulty.compareTo(a.difficulty));

    TextStyle textStyle = textTheme.headline6!.copyWith(color: Colors.black87);

    return Column(
        children: _words
            .map((e) => Container(
                  padding: const EdgeInsets.all(8.0),
                  color: _difficultyColour(e.difficulty, scheme: scheme),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.word, style: textStyle),
                      Text(e.difficulty.toStringAsFixed(2), style: textStyle),
                    ],
                  ),
                ))
            .toList());
  }

  Widget _team(BuildContext context, String id) {
    return EntityFutureBuilder<Team>(
      id: id,
      store: teamStore(),
      loadingWidget: Container(),
      errorWidget: (_) => Icon(Icons.error),
      resultWidget: (team) => InkWell(
        child: Text(
          team.name,
          style: Theme.of(context).textTheme.headline6!.copyWith(color: Colours.correct.darken(0.4)),
        ),
        onTap: () => context.push(Routes.team(id)),
      ),
    );
  }
}
