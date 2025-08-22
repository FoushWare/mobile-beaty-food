import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baty_bites/core/constants/app_constants.dart';

enum AppTextFieldType { text, email, password, phone, number, multiline }

class AppTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final AppTextFieldType type;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.type = AppTextFieldType.text,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.autovalidateMode,
    this.validator,
  });

  const AppTextField.email({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.autovalidateMode,
    this.validator,
  }) : type = AppTextFieldType.email,
       maxLines = 1,
       maxLength = null;

  const AppTextField.password({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.autovalidateMode,
    this.validator,
  }) : type = AppTextFieldType.password,
       maxLines = 1,
       maxLength = null;

  const AppTextField.phone({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.autovalidateMode,
    this.validator,
  }) : type = AppTextFieldType.phone,
       maxLines = 1,
       maxLength = null;

  const AppTextField.multiline({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLines = 4,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.autovalidateMode,
    this.validator,
  }) : type = AppTextFieldType.multiline;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.required)
                Text(
                  ' *',
                  style: TextStyle(color: colorScheme.error),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.type == AppTextFieldType.password ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          obscureText: widget.type == AppTextFieldType.password ? _obscureText : false,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction ?? _getTextInputAction(),
          inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: _focusNode.hasFocus 
                          ? colorScheme.primary 
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: widget.prefixIcon!,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(colorScheme),
            filled: true,
            fillColor: widget.enabled 
                ? colorScheme.surface
                : colorScheme.onSurface.withValues(alpha: 0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.type == AppTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconTheme(
        data: IconThemeData(
          color: _focusNode.hasFocus 
              ? colorScheme.primary 
              : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        child: widget.suffixIcon!,
      );
    }
    
    return null;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.phone:
        return TextInputType.phone;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.multiline:
        return TextInputType.multiline;
      case AppTextFieldType.password:
      case AppTextFieldType.text:
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case AppTextFieldType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case AppTextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      case AppTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }
}