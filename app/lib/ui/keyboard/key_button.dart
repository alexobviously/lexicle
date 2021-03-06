import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class KeyButton extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration animationDuration;
  final double depth;
  final double blurRadius;
  final Color? colour;
  const KeyButton({
    Key? key,
    required this.child,
    this.width = 50,
    this.height = 75,
    this.onTap,
    this.onLongPress,
    this.depth = 2.0,
    this.blurRadius = 10.0,
    this.animationDuration = const Duration(milliseconds: 100),
    this.colour,
  }) : super(key: key);

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton> with SingleTickerProviderStateMixin {
  late double _depth;

  @override
  void initState() {
    _depth = widget.depth;
    super.initState();
  }

  void _onTapDown() async {
    setState(() => _depth = widget.depth * 0.15);
  }

  void _onTapUp() {
    setState(() => _depth = widget.depth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool dark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap != null ? (_) => _onTapDown() : null,
        onTapUp: widget.onTap != null ? (_) => _onTapUp() : null,
        onTapCancel: widget.onTap != null ? _onTapUp : null,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: widget.colour ?? theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(6.0),
            // shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dark ? Colors.white54 : Colors.grey.shade500,
                offset: Offset(_depth, _depth),
                blurRadius: widget.blurRadius,
              ),
              BoxShadow(
                color: dark ? Colors.grey.shade600 : Colors.grey.shade200,
                offset: Offset(-_depth, -_depth),
                blurRadius: widget.blurRadius,
              ),
            ],
          ),
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
