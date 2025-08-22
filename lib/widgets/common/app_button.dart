import 'package:flutter/material.dart';
import 'package:baty_bites/core/constants/app_constants.dart';

enum AppButtonType { primary, secondary, tertiary, outlined }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.primary,
       size = AppButtonSize.medium;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.secondary,
       size = AppButtonSize.medium;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.outlined,
       size = AppButtonSize.medium;

  const AppButton.tertiary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
  }) : type = AppButtonType.tertiary,
       size = AppButtonSize.medium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget button = _buildButton(context, theme, colorScheme);

    if (isExpanded) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final buttonPadding = padding ?? _getPadding();
    final buttonHeight = _getHeight();

    if (type == AppButtonType.tertiary) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: buttonPadding,
          minimumSize: Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        child: _buildContent(context, colorScheme.primary),
      );
    }

    if (type == AppButtonType.outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: buttonPadding,
          minimumSize: Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        child: _buildContent(context, colorScheme.primary),
      );
    }

    // Primary and Secondary buttons
    final backgroundColor = type == AppButtonType.primary
        ? colorScheme.primary
        : colorScheme.secondary;
    final foregroundColor = type == AppButtonType.primary
        ? colorScheme.onPrimary
        : colorScheme.onSecondary;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: buttonPadding,
        minimumSize: Size(0, buttonHeight),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      child: _buildContent(context, foregroundColor),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: textColor, size: _getIconSize()),
            child: icon!,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(context).copyWith(color: textColor),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(context).copyWith(color: textColor),
      textAlign: TextAlign.center,
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (size) {
      case AppButtonSize.small:
        return theme.textTheme.labelSmall ?? const TextStyle();
      case AppButtonSize.medium:
        return theme.textTheme.labelLarge ?? const TextStyle();
      case AppButtonSize.large:
        return theme.textTheme.titleMedium ?? const TextStyle();
    }
  }
}