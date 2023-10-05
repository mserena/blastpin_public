import 'dart:math';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/image_cropper_custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class MediaUtils{
  static Future<XFile?> pickAndCropImage(BuildContext context) async{
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(file != null && context.mounted){
      int croppieBoundaryWidth = (MediaQuery.of(context).size.width * 0.9).round();
      int croppieBoundaryHeight = (MediaQuery.of(context).size.height * 0.8).round();
      int minSize = min(croppieBoundaryWidth,croppieBoundaryHeight)-5;
      int croppieViewPortWidth = defMaxMediaSize;
      int croppieViewPortHeight = defMaxMediaSize;
      if(croppieViewPortWidth > croppieBoundaryWidth || croppieViewPortHeight > croppieBoundaryHeight){
        croppieViewPortWidth = minSize;
        croppieViewPortHeight = minSize;
      }

      WebUiSettings settings = WebUiSettings(
        context: context,
        presentStyle: CropperPresentStyle.page,
        boundary: CroppieBoundary(
          width: croppieBoundaryWidth,
          height: croppieBoundaryHeight,
        ),
        viewPort: CroppieViewPort(
          width: croppieViewPortWidth,
          height: croppieViewPortHeight,
        ),
        enableExif: true,
        enableZoom: true,
        showZoomer: true,
        customRouteBuilder: (cropper, crop, rotate) {
          return PageTransition(
            type: PageTransitionType.fade,
            child: ImageCropperCustomWidget(cropper: cropper, crop: crop, rotate: rotate),
          );
        }
      );

      CroppedFile? fileCropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        maxWidth: croppieViewPortWidth,
        maxHeight: croppieViewPortHeight,
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.png,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [settings],
      );

      if(fileCropped != null){
        file = XFile(fileCropped.path);
      } else {
        file = null;
      }
    }
    return file;
  }
}