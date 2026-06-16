import 'package:lawyer/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme-aware text field used throughout the lawyer app.
///
/// Reads colours from `Theme.of(context).colorScheme` and
/// `inputDecorationTheme` so it flips automatically with light/dark.
/// Focused state gets a soft gold halo for a premium feel.
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscure;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String? helper;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool autofocus;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscure = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.helper,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _focused = false;
  late bool _obscure = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final field = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      maxLines: _obscure ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
      cursorColor: cs.secondary,
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        helperText: widget.helper,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 18, color: cs.onSurfaceVariant),
        suffixIcon: _suffix(cs),
        counterText: '',
      ),
    );

    return AnimatedContainer(
      duration: AppTheme.motionFast,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: _focused && widget.enabled
            ? [
                BoxShadow(
                  color: cs.secondary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: field,
    );
  }

  Widget? _suffix(ColorScheme cs) {
    if (widget.obscure) {
      return IconButton(
        splashRadius: 18,
        icon: Icon(
          _obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
          color: cs.onSurfaceVariant,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (widget.suffixIcon == null) return null;
    return IconButton(
      splashRadius: 18,
      icon: Icon(widget.suffixIcon, size: 18, color: cs.onSurfaceVariant),
      onPressed: widget.onSuffixTap,
    );
  }
}
