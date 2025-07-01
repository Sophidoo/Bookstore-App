import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String placeholder;
  final String? label;
  final bool isPassword;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  final FocusNode? focusNode;
  final bool? enabled;
  final bool? readOnly;
  final String? helperText;
  final bool? numberOnly;
  final AutovalidateMode? autoValidateMode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool showBorder;
  final bool filled;
  final bool boldenText;

  const CustomTextField({
    super.key,
    required this.placeholder,
    this.label,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled,
    this.helperText,
    this.numberOnly,
    this.readOnly,
    this.autoValidateMode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.showBorder = true,
    this.filled = false,
    this.boldenText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;

    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = widget.enabled == false;
    final isReadOnly = widget.readOnly == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              widget.label!,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.onSurface.withValues(alpha: 0.87),
              ),
            ),
          ),
        ] else
          const SizedBox(height: 4),

        TextFormField(
          controller: widget.controller,
          autovalidateMode:
              widget.autoValidateMode ?? AutovalidateMode.onUserInteraction,
          cursorColor: colorScheme.primary,
          cursorWidth: 2.0,
          readOnly: isReadOnly,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          keyboardType:
              widget.numberOnly == true
                  ? TextInputType.number
                  : TextInputType.text,
          inputFormatters:
              widget.inputFormatters ??
              (widget.numberOnly == true
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : []),
          onTapOutside: (e) {
            FocusScope.of(context).unfocus();
          },
          validator: widget.validator,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted,
          style: theme.textTheme.bodyLarge?.copyWith(
            color:
                isDisabled
                    ? colorScheme.onSurface.withValues(alpha: 0.38)
                    : colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: widget.filled,
            fillColor: widget.filled ? _getFillColor(colorScheme) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 15,
            ),

            // Helper and hint text
            helperText: widget.helperText,
            helperStyle: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            hintText: widget.placeholder,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color:
                  widget.boldenText == true
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight:
                  widget.boldenText == true ? FontWeight.bold : FontWeight.w500,
            ),

            // Icons
            prefixIcon:
                widget.prefixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                      child: IconTheme(
                        data: IconThemeData(
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                    : null,
            suffixIcon: _buildSuffixIcon(colorScheme),
            border:
                widget.showBorder
                    ? _buildBorder(colorScheme.onSurface.withValues(alpha: 0.1))
                    : InputBorder.none,
            enabledBorder:
                widget.showBorder
                    ? _buildBorder(colorScheme.onSurface.withValues(alpha: 0.1))
                    : InputBorder.none,
            focusedBorder:
                widget.showBorder
                    ? _buildBorder(colorScheme.onSurface.withValues(alpha: 0.1))
                    : InputBorder.none,
            errorBorder:
                widget.showBorder
                    ? _buildBorder(colorScheme.error)
                    : InputBorder.none,
            focusedErrorBorder:
                widget.showBorder
                    ? _buildBorder(colorScheme.error)
                    : InputBorder.none,
            disabledBorder:
                widget.showBorder
                    ? _buildBorder(colorScheme.onSurface.withValues(alpha: 0.4))
                    : InputBorder.none,

            // Error styling
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  Color _getFillColor(ColorScheme colorScheme) {
    return colorScheme.surface.withValues(alpha: 0.2);
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.isPassword) {
      return Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
          color:
              _isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
          onPressed: _toggleObscureText,
          splashRadius: 20,
        ),
      );
    } else if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: IconTheme(
          data: IconThemeData(
            color:
                _isFocused
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          child: widget.suffixIcon!,
        ),
      );
    }
    return null;
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
