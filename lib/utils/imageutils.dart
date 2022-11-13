import 'dart:io';
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum ImageType { profile, post }

class ImageUtils  {

  static Future<File?> choosImage( ImageType type, BuildContext context) async {
    File? local;
    final getImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    print("getImage: $getImage");
    if (getImage != null) {
      local = File(getImage.path);
    }
    return local;
  }

  static Future<String> getPhotoPath(Uint8List? bytes, String? name) async {
    if (bytes != null){
      final tempDir = await getApplicationDocumentsDirectory();
      File file = await File('${tempDir.path}/$name.png').create();
      file.writeAsBytesSync(bytes!);
      return '${tempDir.path}/$name.png';
    }
    return "res/no-image.png";

  }

  static Future<File?> cropImage(File? imageFile, ImageType type, BuildContext context) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile!.path,
        aspectRatio: type == ImageType.post ? CropAspectRatio(ratioX: 16, ratioY: 9) : null,
        cropStyle: type == ImageType.profile ? CropStyle.circle : CropStyle.rectangle,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.black,
            hideBottomControls: type == ImageType.profile || type == ImageType.post,
            activeControlsWidgetColor: Theme.of(context).colorScheme.secondary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: type == ImageType.profile),
        iosUiSettings: IOSUiSettings(
          aspectRatioLockDimensionSwapEnabled: false,
          hidesNavigationBar: type == ImageType.profile || type == ImageType.post,
          aspectRatioLockEnabled: type == ImageType.profile,
          title: '',
        ));
    return croppedFile;
  }
}