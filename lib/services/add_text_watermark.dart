import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

sealed class AddTextWaterMark {
  const AddTextWaterMark._();

  static Future<File?> addTextWaterMark(
      File imageFile, String watermarkText) async {
    final token = RootIsolateToken.instance!;

    final result = await compute(_watermarkInIsolate, {
      'token': token,
      'imageFilePath': imageFile.path,
      'watermarkText': watermarkText,
    });

    return result;
  }

  // static Future<File>? addTextWaterMark(File? image, {String? text}) async {
  //   final originalImage = img.decodeImage(image!.readAsBytesSync());
  static Future<File?> _watermarkInIsolate(Map<String, dynamic> params) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params['token']);

    final String imagePath = params['imageFilePath'];
    final String watermarkText = params['watermarkText'];

    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return null;

    img.drawString(
      originalImage,
      watermarkText,
      font: img.arial24,
      x: originalImage.width - 235,
      y: originalImage.height - 60,
      color: originalImage.getColor(163, 162, 162),
    );
    final tempDir = await getTemporaryDirectory();
    final _random = Random();
    String randomFileName = _random.nextInt(10000).toString();
    File(tempDir.path + '/$randomFileName.png')
        .writeAsBytesSync(img.encodePng(originalImage));
    return File(tempDir.path + '/$randomFileName.png');
  }
}
