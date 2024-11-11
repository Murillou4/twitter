import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<File> downloadGif(String url) async {
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
