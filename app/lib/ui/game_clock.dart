import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum ClockSide {
  left,
  right,
}

class GameClock extends StatelessWidget {
  final int? time;
  final bool fullDetail;
  final TextStyle? textStyle;
  final double? iconSize;
  final ClockSide clockSide;
  const GameClock(
    this.time, {
    super.key,
    this.fullDetail = false,
    this.textStyle,
    this.iconSize,
    this.clockSide = ClockSide.left,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: time ?? 0);

    final icon = Padding(
      padding: clockSide == ClockSide.left
          ? const EdgeInsets.only(right: 4.0)
          : const EdgeInsets.only(left: 4.0),
      child: Icon(
        MdiIcons.clockOutline,
        size: iconSize,
      ),
    );

    return Row(
      children: [
        if (clockSide == ClockSide.left) icon,
        Text(
          time != null ? _formatTime(duration, fullDetail) : '∞',
          style: textStyle ?? Theme.of(context).textTheme.titleLarge,
        ),
        if (clockSide == ClockSide.right) icon,
      ],
    );
  }

  String _formatTime(Duration duration, [bool fullDetail = false]) {
    String pad(int n) => n.toString().padLeft(2, '0');
    String output = '';
    if (fullDetail || duration.inHours > 0) {
      output = '${pad(duration.inHours)}:';
    }
    output = '$output${pad(duration.inMinutes.remainder(60))}';
    if (fullDetail || duration.inHours == 0) {
      output = '$output:${pad(duration.inSeconds.remainder(60))}';
    }
    return output;
  }
}
