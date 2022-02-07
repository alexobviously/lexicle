import 'dart:math';

import 'package:common/common.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/entity_future_builder.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class StatsView extends StatefulWidget {
  final String id;
  const StatsView({required this.id, Key? key}) : super(key: key);

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
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
                  int _length(int index) => u.guessCounts.keys.toList()[index];

                  return Column(
                    children: [
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: FittedBox(child: _guessChart(u.guessCounts[_length(lengthIndex)] ?? {})),
                        ),
                      ),
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
    int maxCount = _counts.entries.fold(0, (a, b) => max(a, b.value));

    List<BarChartGroupData> _groups = List.generate(
        8,
        (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  y: ((_counts[i + 1] ?? 0) / maxCount) * maxCount,
                  width: 41,
                  colors: [Colours.correct.darken(0.2)],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2.0)),
                  // borderSide: BorderSide(width: 1.0, color: Colors.black54.withOpacity(1.0)),
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
}
