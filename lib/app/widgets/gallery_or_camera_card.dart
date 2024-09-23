import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/widgets/my_loading_circle.dart';

class GalleryOrCameraCard extends StatelessWidget {
  const GalleryOrCameraCard({
    super.key,
    required this.onChoose,
  });
  final Future<void> Function(ImageSource) onChoose;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.drawerBackground,
      title: const Center(
        child: Text(
          'Escolha uma fonte',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () async {
                showLoadingCircle(context);
                await onChoose(ImageSource.camera);
                context.mounted ? hideLoadingCircle(context) : null;
                context.mounted ? Navigator.pop(context) : null;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                  const Gap(10),
                  const Card(
                    color: AppColors.background,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Câmera',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () async {
                showLoadingCircle(context);
                await onChoose(ImageSource.gallery);
                context.mounted ? hideLoadingCircle(context) : null;
                context.mounted ? Navigator.pop(context) : null;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image,
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                  const Gap(10),
                  const Card(
                    color: AppColors.background,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Galeria',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
