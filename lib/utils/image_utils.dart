import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/image_cropper_custom_widget.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageUtils{
  static Future<ImageInfo> getImageInfo({required String path, required BuildContext context}) async {
    AssetImage assetImage = AssetImage(path);
    ImageStream stream = assetImage.resolve(createLocalImageConfiguration(context));
    Completer<ImageInfo> completer = Completer();
    stream.addListener(ImageStreamListener((ImageInfo imageInfo, _) {
        return completer.complete(imageInfo);
      }));
    return completer.future;
  }

  static Future<BitmapDescriptor> createCustomMarkerImageTextBitmap(
  {
    required String imagePath,
    required Size imageSize,
    required String text,
    required TextStyle textStyle,
    Color textBackgroundColor = Colors.transparent
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // draw text
    int textBoxPaddingWidth = 10;
    int textBoxPaddingHeight = 5;
    TextSpan span = TextSpan(
      style: textStyle,
      text: text,
    );
    TextPainter painter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
    );
    painter.text = TextSpan(
      text: text.toString(),
      style: textStyle,
    );
    painter.layout();
    painter.paint(canvas, Offset(textBoxPaddingWidth/2, imageSize.height+textBoxPaddingHeight/2));
    int textWidth = painter.width.toInt();
    int textHeight = painter.height.toInt();
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, imageSize.height, (textWidth + textBoxPaddingWidth).toDouble(), (imageSize.height + textHeight + textBoxPaddingHeight).toDouble(),
          bottomLeft: const Radius.circular(10),
          bottomRight: const Radius.circular(10),
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10)
      ),
      Paint()..color = textBackgroundColor
    );
    painter.layout();
    painter.paint(canvas, Offset(textBoxPaddingWidth/2, imageSize.height+textBoxPaddingHeight/2));

    // draw image
    double textBoxWidth = (textWidth + textBoxPaddingWidth).toDouble();
    double imagePaintLeft = 0;
    if(textBoxWidth > imageSize.width){
      imagePaintLeft = textBoxWidth/2 - imageSize.width/2;
    }
    ImageInfo imageInfo = await getImageInfo(path: imagePath, context: gNavigatorStateKey.currentContext!);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(imagePaintLeft,0, imageSize.width, imageSize.height),
      image: imageInfo.image,
      filterQuality: FilterQuality.low
    );

    ui.Picture p = pictureRecorder.endRecording();
    ByteData? pngBytes = await (
      await p.toImage(painter.width.toInt() + textBoxPaddingWidth, painter.height.toInt() + textBoxPaddingHeight + imageSize.height.toInt())
    ).toByteData(format: ui.ImageByteFormat.png);
    Uint8List data = Uint8List.view(pngBytes!.buffer);
    return BitmapDescriptor.fromBytes(data);
  }

  static double getIconSize(ObjectSize size, {BuildContext? context}){
    //Try to get context
    BuildContext? currentContext;
    if(context != null){
      currentContext = context;
    } else if(gNavigatorStateKey.currentContext != null){
      currentContext = gNavigatorStateKey.currentContext;
    }

    if(currentContext != null){
      DeviceView view = DeviceManager().getDeviceView(currentContext);
      switch(size){
        case ObjectSize.big:
          return view == DeviceView.expanded ? 30 : 25;
        case ObjectSize.normal:
          return view == DeviceView.expanded ? 25 : 20;
        case ObjectSize.small:
          return view == DeviceView.expanded ? 20 : 15;
      }
    }
    return 0;
  }

  static double getSquareButtonSize(ObjectSize size, {BuildContext? context}){
    //Try to get context
    BuildContext? currentContext;
    if(context != null){
      currentContext = context;
    } else if(gNavigatorStateKey.currentContext != null){
      currentContext = gNavigatorStateKey.currentContext;
    }

    if(currentContext != null){
      DeviceView view = DeviceManager().getDeviceView(currentContext);
      switch(size){
        case ObjectSize.big:
          return view == DeviceView.expanded ? 100 : 90;
        case ObjectSize.normal:
          return view == DeviceView.expanded ? 75 : 70;
        case ObjectSize.small:
          return view == DeviceView.expanded ? 50 : 45;
      }
    }
    return 0;
  }

  static Size getFlagSize(ObjectSize size, {BuildContext? context}){
    //Try to get context
    BuildContext? currentContext;
    if(context != null){
      currentContext = context;
    } else if(gNavigatorStateKey.currentContext != null){
      currentContext = gNavigatorStateKey.currentContext;
    }

    double width = 0;
    double height = 0;
    if(currentContext != null){
      DeviceView view = DeviceManager().getDeviceView(currentContext);
      switch(size){
        case ObjectSize.big:
          width = view == DeviceView.expanded ? 60 : 50;
          break;
        case ObjectSize.normal:
          width = view == DeviceView.expanded ? 50 : 40;
          break;
        case ObjectSize.small:
          width = view == DeviceView.expanded ? 40 : 30;
          break;
      }
    }
    if(width != 0){
      height = (3*width)/4;
    }
    return Size(width,height);
  }

  static double getAnimationSize(ObjectSize size, {BuildContext? context}){
    //Try to get context
    BuildContext? currentContext;
    if(context != null){
      currentContext = context;
    } else if(gNavigatorStateKey.currentContext != null){
      currentContext = gNavigatorStateKey.currentContext;
    }

    if(currentContext != null){
      DeviceView view = DeviceManager().getDeviceView(currentContext);
      switch(size){
        case ObjectSize.big:
          return view == DeviceView.expanded ? 70 : 50;
        case ObjectSize.normal:
          return view == DeviceView.expanded ? 50 : 30;
        case ObjectSize.small:
          return view == DeviceView.expanded ? 30 : 20;
      }
    }
    return 0;
  }

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
        String fileExtension = path.extension(file.name);
        String fileName = const Uuid().v4() + fileExtension;
        file = XFile(
          fileCropped.path,
          name: fileName,
          mimeType: file.mimeType
        );
      } else {
        file = null;
      }
    }
    return file;
  }

  static IconData getContentTypeIcon(ContentBlastPinType type){
    switch(type) {
      case ContentBlastPinType.event:
        return FontAwesomeIcons.calendarDays;
      case ContentBlastPinType.place:
        return FontAwesomeIcons.houseChimney;
    }
  }
}