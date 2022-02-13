import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicTextField extends StatelessWidget {
  final double depth;
  final EdgeInsets padding;
  final TextEditingController? controller;
  final bool? enabled;
  final VoidCallback? onClear;
  final FormFieldValidator<String>? validator;
  final void Function(String?)? onSaved;
  final InputDecoration? inputDecoration;
  final String? hintText;
  final Widget? label;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  const NeumorphicTextField({
    Key? key,
    this.depth = -2,
    this.enabled,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.controller,
    this.onClear,
    this.validator,
    this.onSaved,
    this.inputDecoration,
    this.hintText,
    this.label,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -2,
      ),
      padding: padding,
      child: TextFormField(
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLengthEnforcement: maxLength != null ? MaxLengthEnforcement.enforced : MaxLengthEnforcement.none,
        enabled: enabled,
        controller: controller,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        obscureText: obscureText,
        decoration: inputDecoration ??
            InputDecoration(
              hintText: hintText,
              label: label,
              suffixIcon: onClear != null
                  ? IconButton(
                      onPressed: onClear,
                      icon: Icon(Icons.clear),
                    )
                  : null,
            ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
