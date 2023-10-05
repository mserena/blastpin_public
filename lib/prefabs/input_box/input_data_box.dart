import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget createInputDataBox({
  required Key textFormFieldKey, 
  String? title,
  Widget? titleIcon,
  required double width,
  TextEditingController? textController,
  FocusNode? focusNode,
  String? hintText,
  TextStyle? textStyle,
  bool readOnly = false,
  bool autofocus = false,
  bool enabled = true,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? initialValue,
  IconData? icon,
  Color? iconColor,
  Function? onChanged,
  Function? onValidate,
  Widget? extraWidget,
  String? error,
  int? maxLength,
  bool showMaxLengthCounter = true,
  int? maxLines = 1,
  TextAlign textAlign = TextAlign.start,
  Function? onPress
}){
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if(title != null) ...{
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LanguageManager().getText(title),
              textAlign: TextAlign.left,
              style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!
            ),
            if(titleIcon != null) ...{
              const SizedBox(width: 10),
              titleIcon,
            }
          ],
        ),
        const SizedBox(height: 10),
      },
      MouseRegion(
        cursor: onPress == null ? SystemMouseCursors.text : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: (){
            if(onPress != null){
              onPress();
            }
          },
          child: Stack(
            children: [
              SizedBox(
                width: width,
                child: IgnorePointer(
                  ignoring: onPress != null,
                  child: TextFormField(
                    key: textFormFieldKey,
                    textAlign: textAlign,
                    controller: textController,
                    focusNode: focusNode,
                    maxLines: maxLines,
                    initialValue: textController == null ? initialValue : null,
                    readOnly: readOnly,
                    autofocus: autofocus,
                    enabled: enabled,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    maxLength: maxLength,
                    style: textStyle ?? Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
                    cursorColor: defPrimaryColor,
                    decoration: InputDecoration(
                      hintText: hintText != null ? LanguageManager().getText(hintText) : '',
                      hintStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.labelMedium!,
                      counterStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodySmall!,
                      counterText: maxLength != null && showMaxLengthCounter ? null : '',
                      icon: icon == null ? null : Icon(
                        icon,
                        color: iconColor ?? defPrimaryColor,
                        size: ImageUtils.getIconSize(ObjectSize.normal),
                      ),
                      border: InputBorder.none,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: defPrimaryColor,
                          width: 2,
                        ),   
                      ), 
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: defPrimaryColor,
                          width: 2,
                        ),   
                      ),  
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onChanged: (String text) => {
                      if(onChanged != null){
                        onChanged(text)
                      }
                    },
                  ),
                ),
              ),
              if(onPress != null) ...{
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    color: Colors.transparent
                  )
                ),
              }
            ]
          ),
        ),
      ),
      if(error != null) ...{
        const SizedBox(height: 10),
        Text(
          LanguageManager().getText(error),
          textAlign: TextAlign.left,
          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.labelMedium!.copyWith(color: defErrorTextColor),
        ),
      },
      if(extraWidget != null) ...{
        extraWidget,
      }
    ]
  );
}
