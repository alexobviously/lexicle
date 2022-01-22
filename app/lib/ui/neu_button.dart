import 'package:flutter/material.dart';

class NeuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final double rounding;
  const NeuButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.all(12.0),
    this.elevation = 2.0,
    this.rounding = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        child: child,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(rounding),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              offset: Offset(elevation, elevation),
              blurRadius: 12.0,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-elevation, -elevation),
              blurRadius: 12.0,
            ),
          ],
        ),
      ),
    );
  }
}
