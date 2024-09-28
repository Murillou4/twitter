import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/widgets/gallery_or_camera_card.dart';
import 'package:twitter/app/widgets/my_button.dart';
import 'package:twitter/app/widgets/my_loading_circle.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class InputPostDialog extends StatefulWidget {
  const InputPostDialog({
    super.key,
  });

  @override
  State<InputPostDialog> createState() => _InputPostDialogState();
}

class _InputPostDialogState extends State<InputPostDialog> {
  File? image;
  TextEditingController postController = TextEditingController();
  late final databaseController =
      Provider.of<DatabaseController>(context, listen: false);

  Future<void> selectImage(BuildContext context, ImageSource source,
      [bool isGif = false]) async {
    if (isGif) {
      final gif = await GiphyPicker.pickGif(
        context: context,
        apiKey: 'LgLuuMlL3aaDQHRHL5gXsVtgHY9woHTU',
        appBarBuilder: (context, {actions, title}) {
          return AppBar(
            title: title,
            actions: actions,
          );
        },
      );
      if (gif == null) return;

      // Baixa o GIF da URL e salva localmente
      final gifUrl = gif.images.original!.url;
      final gifFile = await _downloadGif(gifUrl!);

      setState(() {
        image = gifFile;
      });
    } else {
      final imageAux = await ImagePicker().pickImage(source: source);
      if (imageAux == null) return;
      final imageTemporary = File(imageAux.path);
      setState(() {
        image = imageTemporary;
      });
    }
  }

  Future<File> _downloadGif(String url) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = url.split('/').last;
    final savePath = '${appDir.path}/$fileName';

    try {
      await Dio().download(url, savePath);
      return File(savePath);
    } catch (e) {
      print("Erro ao baixar o GIF: $e");
      throw Exception("Erro ao baixar o GIF");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.drawerBackground,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: postController,
            maxLength: 200,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Escreva um tweet',
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
          const Gap(10),
          Row(
            children: [
              image == null
                  ? Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => GalleryOrCameraCard(
                              onChoose: selectImage,
                              isGif: true,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.image_search_rounded,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          child: Image.file(
                            fit: BoxFit.cover,
                            image!,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              image = null;
                            });
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
              const Gap(10),
            ],
          ),
        ],
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        MyButton(
          onTap: () {
            postController.clear();
            Navigator.of(context).pop();
          },
          buttonColor: AppColors.background,
          textColor: AppColors.white,
          text: 'Cancelar',
          width: 100,
        ),
        MyButton(
          onTap: () async {
            if (postController.text.isEmpty) {
              Navigator.of(context).pop();
              return;
            }
            showLoadingCircle(context);
            await databaseController.addNewPost(
                text: postController.text, image: image);
            context.mounted ? hideLoadingCircle(context) : null;
            postController.clear();
            context.mounted ? Navigator.of(context).pop() : null;
          },
          buttonColor: AppColors.background,
          textColor: AppColors.white,
          text: 'Postar',
          width: 100,
        )
      ],
    );
  }
}
