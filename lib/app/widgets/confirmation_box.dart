import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/widgets/my_button.dart';

Future<bool> showConfirmationBox({
  required BuildContext context,
  required String title,
  required String confirmationText,
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
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          MyButton(
            buttonColor: AppColors.background,
            textColor: AppColors.white,
            text: 'Cancelar',
            onTap: () {
              Navigator.of(context).pop(
                false,
              );
              return false;
            },
            width: 100,
          ),
          MyButton(
            buttonColor: AppColors.background,
            textColor: AppColors.white,
            text: confirmationText,
            onTap: () {
              Navigator.of(context).pop(true);
              return true;
            },
            width: 100,
          ),
        ],
      );
    },
  );
}
