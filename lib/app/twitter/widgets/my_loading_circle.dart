import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';

void showLoadingCircle(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      );
    },
  );
}

void hideLoadingCircle(BuildContext context) {
  Navigator.of(context).pop();
}
