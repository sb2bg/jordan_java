import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveImage(int index, BuildContext context) async {
  final imagePicker = ImagePicker();

  if (!await _checkPermission(context)) return;

  final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    final cropper = ImageCropper();

    final croppedImage = await cropper.cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 700,
      maxHeight: 700,
      compressFormat: ImageCompressFormat.jpg,
    );

    if (croppedImage != null) {
      final imageFile = File(croppedImage.path);
      final imagePath = await _getImagePath(index);
      await imageFile.copy(imagePath);
    }
  }
}

Future<File> getImage(int index) async {
  final imagePath = await _getImagePath(index);
  return File(imagePath);
}

Future<String> _getImagePath(int index) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagesDirectory = Directory('${directory.path}/images');
  await imagesDirectory.create(recursive: true);
  return '${imagesDirectory.path}/image$index.jpg';
}

Future<bool> _checkPermission(BuildContext context) async {
  final status = await Permission.mediaLibrary.request();

  if (status.isDenied) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
            'Please allow access to storage in order to save images.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  return status.isGranted;
}
