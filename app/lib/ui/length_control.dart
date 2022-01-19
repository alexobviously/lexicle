import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LengthControl extends StatelessWidget {
  final int length;
  final int min;
  final int max;
  final Function(int) onChanged;
  const LengthControl({
    Key? key,
    required this.length,
    this.min = 4,
    this.max = 8,
    required this.onChanged,
  }) : super(key: key);
  static const double iconSize = 24;

  bool get canDecrease => length > min;
  bool get canIncrease => length < max;

  void _decrease() {
    if (canDecrease) {
      onChanged(length - 1);
    }
  }

  void _increase() {
    if (canIncrease) {
      onChanged(length + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: canDecrease ? _decrease : null,
          icon: const Icon(
            MdiIcons.chevronLeft,
            size: iconSize,
          ),
        ),
        ...List.filled(
          length,
          const Icon(
            MdiIcons.cropSquare,
            size: iconSize,
          ),
        ),
        IconButton(
          onPressed: canIncrease ? _increase : null,
          icon: const Icon(
            MdiIcons.chevronRight,
            size: iconSize,
          ),
        ),
      ],
    );
  }
}
