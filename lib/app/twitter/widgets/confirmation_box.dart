import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';

Future<void> showConfirmationBox({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmationText,
  required VoidCallback onConfirm,
}) async {
  return await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.drawerBackground,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          MyButton(
            buttonColor: AppColors.background,
            textColor: AppColors.white,
            text: 'Cancelar',
            onTap: () {
              Navigator.of(context).pop();
            },
            width: 100,
          ),
          MyButton(
            buttonColor: Colors.red,
            textColor: AppColors.white,
            text: confirmationText,
            onTap: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            width: 100,
          ),
        ],
      );
    },
  );
}
