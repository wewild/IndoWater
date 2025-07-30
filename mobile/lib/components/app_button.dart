import 'package:flutter/material.dart';
import 'package:indowater_mobile/utils/constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button height based on size
    double buttonHeight;
    switch (size) {
      case ButtonSize.small:
        buttonHeight = Constants.buttonHeightSmall;
        break;
      case ButtonSize.medium:
        buttonHeight = Constants.buttonHeightMedium;
        break;
      case ButtonSize.large:
        buttonHeight = Constants.buttonHeightLarge;
        break;
    }
    
    // Determine button style based on type
    ButtonStyle buttonStyle;
    switch (type) {
      case ButtonType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Constants.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
          ),
        );
        break;
      case ButtonType.secondary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Constants.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
          ),
        );
        break;
      case ButtonType.outline:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: theme.primaryColor,
          side: BorderSide(color: theme.primaryColor),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Constants.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
          ),
        );
        break;
      case ButtonType.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: theme.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Constants.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
          ),
        );
        break;
    }
    
    // Determine text style based on size
    TextStyle textStyle;
    switch (size) {
      case ButtonSize.small:
        textStyle = theme.textTheme.labelMedium!;
        break;
      case ButtonSize.medium:
        textStyle = theme.textTheme.labelLarge!;
        break;
      case ButtonSize.large:
        textStyle = theme.textTheme.titleMedium!;
        break;
    }
    
    // Build button content
    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        height: size == ButtonSize.small ? 16 : 20,
        width: size == ButtonSize.small ? 16 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.text
                ? theme.primaryColor
                : Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: size == ButtonSize.small ? 16 : 20,
          ),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    } else {
      buttonContent = Text(text, style: textStyle);
    }
    
    // Build button
    Widget button;
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
    }
    
    // Apply width and height constraints
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height ?? buttonHeight,
      child: button,
    );
  }
}