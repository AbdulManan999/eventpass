import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/utils/colors.dart';

/// Labelled text field used on every form. Keeps focus/controller external so
/// the screen owns (and disposes) them.
class CustomizableTextField extends StatelessWidget {
  const CustomizableTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.title,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.hideText = false,
    this.readOnly = false,
    this.isRequired = false,
    this.textInputType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.onFieldSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String? title;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool hideText;
  final bool readOnly;
  final bool isRequired;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmit;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: c, width: 1.2),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text.rich(
            TextSpan(
              text: title,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: context.palette.label),
              children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: redColor))],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          onChanged: onChanged,
          obscureText: hideText,
          readOnly: readOnly,
          keyboardType: textInputType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLines: hideText ? 1 : maxLines,
          onFieldSubmitted: onFieldSubmit,
          style: TextStyle(fontSize: 14.sp, color: context.palette.heading),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14.sp, color: context.palette.hint),
            filled: true,
            fillColor: context.palette.inputFill,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: context.palette.hint) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(icon: Icon(suffixIcon, color: context.palette.hint), onPressed: onSuffixIconPressed)
                : null,
            enabledBorder: _border(context.palette.inputBorder),
            focusedBorder: _border(primaryColor),
            errorBorder: _border(redColor),
            focusedErrorBorder: _border(redColor),
          ),
        ),
      ],
    );
  }
}
