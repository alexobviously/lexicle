import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class KeyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration animationDuration;
  final double depth;
  final double blurRadius;
  final Color? colour;
  const KeyButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.depth = 2.0,
    this.blurRadius = 10.0,
    this.animationDuration = const Duration(milliseconds: 150),
    this.colour,
  }) : super(key: key);

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton> with SingleTickerProviderStateMixin {
  late AnimationController ac;

  late double _depth;

  @override
  void initState() {
    _depth = widget.depth;
    super.initState();
  }

  void _onTapDown() async {
    setState(() => _depth = 0.0);
  }

  void _onTapUp() {
    setState(() => _depth = widget.depth);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapUp,
        // onTapDown: (_) => ac.forward(),
        // onTapCancel: () => ac.reverse(),
        // onTapUp: (_) => ac.reverse(),
        child: AnimatedContainer(
          duration: widget.animationDuration,
          width: 50,
          height: 75,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: widget.colour ?? Colors.grey[300],
            borderRadius: BorderRadius.circular(6.0),
            // shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                offset: Offset(_depth, _depth),
                blurRadius: widget.blurRadius,
              ),
              BoxShadow(
                color: Colors.white,
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
