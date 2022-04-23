import 'dart:async';
import 'dart:math';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:word_game/ui/game_clock.dart';

class CountdownClock extends StatefulWidget {
  final int endTime;
  final bool fullDetail;
  final TextStyle? textStyle;
  final double? iconSize;
  final ClockSide clockSide;
  const CountdownClock(
    this.endTime, {
    Key? key,
    this.fullDetail = false,
    this.textStyle,
    this.iconSize,
    this.clockSide = ClockSide.left,
  }) : super(key: key);

  @override
  State<CountdownClock> createState() => _CountdownClockState();
}

class _CountdownClockState extends State<CountdownClock> {
  late Timer timer;
  late int timeLeft;

  @override
  void initState() {
    _updateTimeLeft(false);
    timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTimeLeft());
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _updateTimeLeft([bool ss = true]) {
    timeLeft = max(0, widget.endTime - nowMs());
    if (ss) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GameClock(
      timeLeft,
      fullDetail: widget.fullDetail,
      textStyle: widget.textStyle,
      iconSize: widget.iconSize,
      clockSide: widget.clockSide,
    );
  }
}
