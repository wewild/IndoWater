import 'package:flutter/material.dart';
import 'package:indowater_mobile/utils/constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool hasShadow;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final card = Container(
      padding: padding ?? const EdgeInsets.all(Constants.paddingMedium),
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
        border: border,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation ?? Constants.cardElevationMedium,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
        child: card,
      );
    }
    
    return card;
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final bool hasDivider;
  final EdgeInsetsGeometry? padding;

  const AppCardHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTrailingTap,
    this.hasDivider = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: Constants.marginMedium),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                if (onTrailingTap != null)
                  InkWell(
                    onTap: onTrailingTap,
                    borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                    child: trailing!,
                  )
                else
                  trailing!,
              ],
            ],
          ),
        ),
        if (hasDivider) ...[
          const SizedBox(height: Constants.marginMedium),
          Divider(
            height: 1,
            thickness: Constants.dividerThickness,
            color: theme.dividerColor,
          ),
          const SizedBox(height: Constants.marginMedium),
        ],
      ],
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final List<Widget> actions;
  final bool hasDivider;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;

  const AppCardFooter({
    Key? key,
    required this.actions,
    this.hasDivider = true,
    this.alignment = MainAxisAlignment.end,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        if (hasDivider) ...[
          const SizedBox(height: Constants.marginMedium),
          Divider(
            height: 1,
            thickness: Constants.dividerThickness,
            color: theme.dividerColor,
          ),
          const SizedBox(height: Constants.marginMedium),
        ],
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: alignment,
            children: actions.map((action) {
              final index = actions.indexOf(action);
              return Padding(
                padding: EdgeInsets.only(
                  left: index > 0 ? Constants.marginSmall : 0,
                ),
                child: action,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}