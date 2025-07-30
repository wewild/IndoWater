import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indowater_mobile/utils/constants.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final bool showClearButton;
  final bool showBorder;
  final bool filled;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.showClearButton = false,
    this.showBorder = true,
    this.filled = true,
    this.fillColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _controller.removeListener(_updateHasText);
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Build suffix icon
    Widget? suffixIconWidget;
    if (widget.obscureText) {
      suffixIconWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: theme.hintColor,
        ),
        onPressed: _toggleObscureText,
      );
    } else if (widget.showClearButton && _hasText) {
      suffixIconWidget = IconButton(
        icon: Icon(
          Icons.clear,
          color: theme.hintColor,
        ),
        onPressed: _clearText,
      );
    } else if (widget.suffixIcon != null) {
      suffixIconWidget = Icon(
        widget.suffixIcon,
        color: theme.hintColor,
      );
    } else if (widget.suffix != null) {
      suffixIconWidget = widget.suffix;
    }
    
    // Build prefix icon
    Widget? prefixIconWidget;
    if (widget.prefixIcon != null) {
      prefixIconWidget = Icon(
        widget.prefixIcon,
        color: theme.hintColor,
      );
    } else if (widget.prefix != null) {
      prefixIconWidget = widget.prefix;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          textCapitalization: widget.textCapitalization,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
            filled: widget.filled,
            fillColor: widget.fillColor ?? theme.inputDecorationTheme.fillColor,
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
              horizontal: Constants.paddingMedium,
              vertical: Constants.paddingMedium,
            ),
            prefixIcon: prefixIconWidget,
            suffixIcon: suffixIconWidget,
            border: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                    ),
                  )
                : InputBorder.none,
            enabledBorder: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                    ),
                  )
                : InputBorder.none,
            focusedBorder: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 2.0,
                    ),
                  )
                : InputBorder.none,
            errorBorder: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                    ),
                  )
                : InputBorder.none,
            focusedErrorBorder: widget.showBorder
                ? OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2.0,
                    ),
                  )
                : InputBorder.none,
          ),
        ),
      ],
    );
  }
}