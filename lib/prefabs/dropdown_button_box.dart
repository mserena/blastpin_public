import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget createDropdownButtonBox({
  Key? key, 
  required dynamic options,
  dynamic currentOption,
  Map<dynamic,String>? customOptionTitles,
  double? width,
  bool isExpanded = true,
  FocusNode? focusNode,
  IconData? iconLeft,
  Function? onChanged,
}){
  return SizedBox(
    width: width,
    child: DropdownButtonFormField<dynamic>(
      key: key,
      iconEnabledColor: defPrimaryColor,
      icon: Icon(
        FontAwesomeIcons.caretDown,
        color: defPrimaryColor,
        size: ImageUtils.getIconSize(ObjectSize.normal),
      ),
      style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        icon: iconLeft == null ? null : Icon(
          iconLeft,
          color: defPrimaryColor,
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
      isExpanded: isExpanded,
      value: currentOption ?? options.first,
      items: options.map<DropdownMenuItem>((dynamic option) {
        String title = TextUtils.stringFromEnum(option).toCapitalized();
        if(customOptionTitles != null && customOptionTitles.containsKey(option)){
          title = customOptionTitles[option]!;
        }
        return DropdownMenuItem(
          value: option,
          child: Center(
            child: Text(
              LanguageManager().getText(title),
              style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
            )
          )
        );
      }).toList(),
      onChanged: (value) {
        if(onChanged != null){
          onChanged(value);
        }
      },
    ),
  );
}