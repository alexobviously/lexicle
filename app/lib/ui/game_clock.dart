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
    Key? key,
    this.fullDetail = false,
    this.textStyle,
    this.iconSize,
    this.clockSide = ClockSide.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: time ?? 0);

    final _icon = Padding(
      padding: clockSide == ClockSide.left ? EdgeInsets.only(right: 4.0) : EdgeInsets.only(left: 4.0),
      child: Icon(
        MdiIcons.clockOutline,
        size: iconSize,
      ),
    );

    return Row(
      children: [
        if (clockSide == ClockSide.left) _icon,
        Text(
          time != null ? _formatTime(duration, fullDetail) : '∞',
          style: textStyle ?? Theme.of(context).textTheme.headline6,
        ),
        if (clockSide == ClockSide.right) _icon,
      ],
    );
  }

  String _formatTime(Duration duration, [bool fullDetail = false]) {
    String _pad(int n) => n.toString().padLeft(2, "0");
    String output = '';
    if (fullDetail || duration.inHours > 0) output = '${_pad(duration.inHours)}:';
    output = '$output${_pad(duration.inMinutes.remainder(60))}';
    if (fullDetail || duration.inHours == 0) output = '$output:${_pad(duration.inSeconds.remainder(60))}';
    return output;
  }
}
