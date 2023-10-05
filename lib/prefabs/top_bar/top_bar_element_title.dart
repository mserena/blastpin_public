import 'package:flutter/material.dart';

Widget createTopBarElementTitle({required String title, required TextStyle style, Function? onTap})
{
  return GestureDetector(
    onTap: () {
      if(onTap != null){
        onTap();
      }
    },
    child: Text(
      title,
      textAlign: TextAlign.center,
      style: style
    )
  ); 
}