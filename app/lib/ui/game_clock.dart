import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class GameClock extends StatelessWidget {
  final int? time;
  final bool fullDetail;
  final TextStyle? textStyle;
  final double? iconSize;
  const GameClock(
    this.time, {
    Key? key,
    this.fullDetail = false,
    this.textStyle,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: time ?? 0);

    return Row(
      children: [
        Icon(
          MdiIcons.clockOutline,
          size: iconSize,
        ),
        Container(width: 4),
        Text(
          time != null ? _formatTime(duration, fullDetail) : '∞',
          style: textStyle ?? Theme.of(context).textTheme.headline6,
        ),
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
