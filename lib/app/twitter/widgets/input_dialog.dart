import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';

class InputDialog extends StatelessWidget {
  const InputDialog({
    super.key,
    required this.hintText,
    required this.onTapText,
    this.onTap,
    required this.controller,
  });
  final TextEditingController controller;
  final String hintText;
  final String onTapText;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.drawerBackground,
      title: TextField(
        controller: controller,
        maxLength: 200,
        maxLines: 8,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.lightGrey,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.background,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.background,
            ),
          ),
        ),
        style: const TextStyle(
          color: AppColors.white,
        ),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        MyButton(
          onTap: () {
            controller.clear();
            Navigator.of(context).pop();
          },
          buttonColor: AppColors.background,
          textColor: AppColors.white,
          text: 'Cancelar',
          width: 100,
        ),
        MyButton(
          onTap: onTap,
          buttonColor: AppColors.background,
          textColor: AppColors.white,
          text: onTapText,
          width: 100,
        )
      ],
    );
  }
}
