import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          enabled: enabled,
          readOnly: readOnly,
          focusNode: focusNode,
          textInputAction: textInputAction,
          autofocus: autofocus,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: Colors.grey[600],
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixIconTap,
                    child: Icon(
                      suffixIcon,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool showClearButton;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText ?? 'البحث...',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey[600],
          size: 24,
        ),
        suffixIcon: showClearButton && controller?.text.isNotEmpty == true
            ? IconButton(
                onPressed: onClear ?? () => controller?.clear(),
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[600],
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<T> items;
  final String Function(T) itemText;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const CustomDropdownField({
    super.key,
    this.labelText,
    this.hintText,
    required this.value,
    required this.items,
    required this.itemText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemText(item)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: Colors.grey[600],
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
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
}


