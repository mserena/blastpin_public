import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';

Widget createButtonGeneric(
  String text,
  Function onPress,
  {
    EdgeInsets padding = const EdgeInsets.fromLTRB(50, 15, 50, 15),
    bool enabled = true,
    IconData? icon,
    double? iconSize,
    Function? onPressDisabled,
    Color? backgroundColor,
    Color? borderColor,
  }){
  return GestureDetector(
    onTap: !enabled && onPressDisabled != null ? () {onPressDisabled();} : null,
    child: ElevatedButton(
      onPressed: enabled ? () {onPress();} : null,
      style: ElevatedButton.styleFrom(
        disabledMouseCursor: (!enabled && onPressDisabled != null) || enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: backgroundColor,
        side: borderColor == null ? null : BorderSide(
          width: 2,
          color: borderColor
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if(icon != null) ...{
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,0,0,0),
                child: Icon(
                  icon,
                  size: iconSize ?? ImageUtils.getIconSize(ObjectSize.normal),
                ),
              ),
            ),
          },
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: padding,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  LanguageManager().getText(text),
                  style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!.copyWith(fontFamily: 'Lexend-SemiBold'),
                ),
              ),
            ),
          ),
        ],
      ),
    )
  );
}