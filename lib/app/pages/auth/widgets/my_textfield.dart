import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';

class MyTextfield extends StatefulWidget {
  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.maxLength,
  });
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final int? maxLength;
  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLength: widget.maxLength,
      style: const TextStyle(
        color: AppColors.white,
      ),
      obscureText: widget.isPassword ? obscureText : false,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColors.white,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: AppColors.white,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.white,
                ),
              )
            : null,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.white,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.white,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
      ),
    );
  }
}
