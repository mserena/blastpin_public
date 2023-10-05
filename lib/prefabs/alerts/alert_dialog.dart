import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/alert_custom_button.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Alert createAlertDialogOptions(
  BuildContext context,
  List<AlertCustomButton> options,
  Function setter,
  {
    String? title,
    String? desc,
    bool closeButton = false,
    bool tapDismiss = false
  }
){
  return createBasicAlert(
    context,
    title: title,
    desc: desc,
    closeButton: closeButton,
    tapDismiss: tapDismiss,
    content: Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: [
          for (int idxButton = 0; idxButton < options.length; idxButton++) ...{
            options[idxButton].build(context,setter),
            if(idxButton != options.length-1) ...{
              const SizedBox(height: 15),
            }
          }
        ],
      )
    )
  );
}

Alert createAlertDialogYesNot(
  BuildContext context,
  {
    String? title,
    String? desc,
    bool closeButton = false,
    bool tapDismiss = false
  }
){
  return createBasicAlert(
    context,
    title: title,
    desc: desc,
    closeButton: closeButton,
    tapDismiss: tapDismiss,
    buttons: [
      DialogButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        color: defPrimaryColor,
        child: Text(
          LanguageManager().getText("Yes"),
          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!.copyWith(fontFamily: 'Lexend-SemiBold'),
        ),
      ),
      DialogButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
        color: defPrimaryColor,
        child: Text(
          LanguageManager().getText("Not"),
          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!.copyWith(fontFamily: 'Lexend-SemiBold'),
        ),
      ),
    ],
  );
}

Alert createBasicAlert(
  BuildContext context,
  {
    String? title,
    String? desc,
    bool closeButton = false,
    bool tapDismiss = false,
    List<DialogButton> buttons = const [],
    Widget content = const SizedBox(),
  }
){
  return Alert(
    context: context,
    type: AlertType.none,
    style: AlertStyle(
      alertAlignment: Alignment.bottomCenter,
      animationType: AnimationType.fromBottom,
      overlayColor: Colors.black.withAlpha(175),
      isCloseButton: closeButton,
      isOverlayTapDismiss: tapDismiss,
      titleStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineLarge!,
      descStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
      backgroundColor: defBackgroundPrimaryColor,
      alertBorder: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0)
        ),
      ),
    ),
    closeIcon: Icon(
      FontAwesomeIcons.xmark,
      size: ImageUtils.getIconSize(ObjectSize.normal),
      color: defPrimaryColor,
    ),
    title: title,
    desc: desc,
    buttons: buttons,
    content: SizedBox(
      width: MediaQuery.of(context).size.width-20,
      child: content
    ),
  );
}