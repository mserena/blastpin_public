import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:flutter/material.dart';

class AlertCustomButton{
  String text;
  dynamic identifier;
  IconData? icon;
  bool secondary;

  AlertCustomButton({required this.text, required this.identifier, this.icon, this.secondary = false});

  Widget build(BuildContext context, Function setter){
    return createButtonGeneric(
      LanguageManager().getText(text), 
      icon: icon,
      (){
        setter(identifier);
        Navigator.of(context, rootNavigator: true).pop(true);
      },
      backgroundColor: secondary ? defBackgroundPrimaryColor : null,
      borderColor: secondary ? defBodyTextColor : null,
    );
  }
}