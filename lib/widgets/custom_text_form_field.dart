

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      {super.key,
      required this.controller,
      this.focusNode,
      this.maxLength,
      required this.hintText,
      this.validator,
      this.suffixIcon,
      this.keyboardType,
      this.textInputAction,
      this.obscureText = false,
      this.onFieldSubmitted,
      this.inputFormatters,
      this.prefix,
      this.padding = 6,
      this.maxlines,
      this.minlines = 1});

  final TextEditingController controller;
  FocusNode? focusNode;
  Widget? suffixIcon;
  Widget? prefix;
  int? maxLength;
  final String hintText;
  TextInputType? keyboardType;
  TextInputAction? textInputAction;
  bool? obscureText;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String?)? validator;
  Function(String)? onFieldSubmitted;
  int? maxlines, minlines;
  double? padding;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      obscureText: obscureText!,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      minLines: minlines,
      maxLines: maxlines,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(padding!),
        prefix: prefix,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
