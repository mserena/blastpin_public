import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:flutter/material.dart';

Widget createBottomBarEditContent(BuildContext context, bool continueEnabled, Function onPressContinue, {String text = 'Continue'}){
  double viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: defTopBarHeigth*1.3,
      width: MediaQuery.of(context).size.width,
      color: defBackgroundPrimaryColor,
      child: Container(
        color: Colors.white.withAlpha(25),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    color: defBackgroundPrimaryColor,
                    height: 8,
                  ),
                  Container(
                    height: 2,
                    width: viewWidth,
                    color: defDisabledTextColor,
                  ),
                ],
              )
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: viewWidth/1.5,
                height: defTopBarHeigth/1.5,
                child: createButtonGeneric(
                  text,
                  onPressContinue,
                  padding: const EdgeInsets.all(0),
                  enabled: continueEnabled
                )
              ) 
            )
          ],
        )  
      )
    )
  );
}