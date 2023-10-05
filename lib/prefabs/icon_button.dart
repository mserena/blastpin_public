import 'package:blastpin/defines/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget createIconButton(
  {
    required IconData icon,
    Color iconColor = defPrimaryColor,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(10)),
    Color backgroundColor = Colors.transparent,
    double iconSize = 25,
    double width = 60,
    double height = 60,
    bool animation = false,
    Function? onPress,
  })
{
  return MouseRegion(
    cursor: onPress != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: (){
        if(onPress != null){
          onPress();
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown, 
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              if(animation)...{
                SpinKitRipple(
                  size: width,
                  borderWidth: 4,
                  color: defPrimaryColor.withAlpha(200),
                  duration: const Duration(seconds: 2),
                ),
              },
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              )
            ],
          )
        ),
      )
    )
  );
}