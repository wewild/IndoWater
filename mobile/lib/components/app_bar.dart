import 'package:flutter/material.dart';
import 'package:indowater_mobile/utils/constants.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final double height;

  const AppTopBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.height = kToolbarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0));
}

class AppSearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final Widget? leading;
  final List<Widget>? actions;

  const AppSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.backgroundColor,
    this.foregroundColor,
    this.height = kToolbarHeight,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: leading ?? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: foregroundColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: foregroundColor?.withOpacity(0.6) ?? theme.hintColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Constants.paddingMedium,
            vertical: Constants.paddingSmall,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) {
                      onClear!();
                    }
                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                )
              : null,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<String> tabs;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final double height;

  const AppTabBar({
    Key? key,
    required this.tabController,
    required this.tabs,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 3.0,
    this.labelPadding,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.height = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TabBar(
      controller: tabController,
      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      indicatorColor: indicatorColor ?? theme.primaryColor,
      labelColor: labelColor ?? theme.primaryColor,
      unselectedLabelColor: unselectedLabelColor ?? theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      indicatorWeight: indicatorWeight,
      labelPadding: labelPadding,
      labelStyle: labelStyle ?? theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: unselectedLabelStyle ?? theme.textTheme.titleSmall,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}