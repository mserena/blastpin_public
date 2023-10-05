import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/material.dart';

// Colors
const Color defBackgroundPrimaryColor = Color(0xFF303030);
const Color defBackgroundSecondaryColor = Color.fromARGB(255, 33, 33, 33);
const Color defBackgroundTertiaryColor = Color.fromARGB(255, 17, 17, 17);
const Color defBackgroundContentCompactColor = Color.fromARGB(255, 75, 75, 75);
Color defWidgetLoadingColor = Colors.grey.withAlpha(150);
const Color defPrimaryColor = Color(0xFFF76C11);
const Color defPrimaryGradientColor = Color(0xFFf87723);
const Color defBodyTextColor = Colors.grey;
const Color defBodyContrastTextColor = Colors.white;
const Color defBodyImportantTextColor = Colors.yellowAccent;
const Color defErrorTextColor = Colors.redAccent;
Color defDisabledTextColor = Colors.grey.withAlpha(150);
const Color defTagEnabledBackgroundColor = Color(0xFFd125b7);
const Color defTagDisabledBackgroundColor = Color(0x969E9E9E);

// Sizes & Spaces
const double defTopBarHeigth = 70;
const double defMaxButtonWidth = 500;
const double defMaxSignInViewWidth = 500;
const double defMaxEditContentViewWidth = 500;
const int defMaxMediaSize = 500;
const double defStepIndicatorMaxWidth = 70;
const double defMaxInfoWindowWidth = 300;
const double defInfoWindowHeigth = 70;
const double defInfoWindowOffset = 50;
const double defMinMyContentMenuView = 400;
const double defMinMyContentView = 400;

// Theme
ThemeData blastpinTheme(BuildContext context){
  //TextTheme
  TextTheme blastpinTextTheme(TextTheme base){
    return base.copyWith(
      bodySmall: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.small, context: context),
        fontFamily: 'Lexend-Regular',
        color: defBodyTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.normal, context: context),
        fontFamily: 'Lexend-Regular',
        color: defBodyTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.normal, context: context),
        fontFamily: 'Lexend-Regular',
        color: defBodyContrastTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.big, context: context),
        fontFamily: 'Lexend-SemiBold',
        color: defBodyContrastTextColor,
      ),
      titleSmall: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.small, context: context),
        fontFamily: 'Lexend-Regular',
        color: defBodyContrastTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.small, context: context),
        fontFamily: 'Lexend-Regular',
        color: defPrimaryColor,
      ), 
      headlineMedium: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.normal, context: context),
        fontFamily: 'Lexend-Regular',
        color: defPrimaryColor,
      ), 
      headlineLarge: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.big, context: context),
        fontFamily: 'Lexend-SemiBold',
        color: defPrimaryColor,
      ), 
      displayLarge: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.big, context: context),
        fontFamily: 'Lexend-SemiBold',
        color: defBodyTextColor,
      ),
      labelMedium: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.normal, context: context),
        fontFamily: 'Lexend-Regular',
        color: defDisabledTextColor,
      ),
      labelSmall: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.small, context: context),
        fontFamily: 'Lexend-Regular',
        color: defBackgroundPrimaryColor,
      ), 
      labelLarge: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.big, context: context),
        fontFamily: 'Lexend-SemiBold',
        color: defBodyContrastTextColor,
        shadows: const [Shadow(color: Colors.grey, blurRadius: 8.0)],
      ),  
      displayMedium: TextStyle(
        fontSize: TextUtils.getFontSize(ObjectSize.normal, context: context),
        fontFamily: 'Lexend-Regular',
        color: defBodyImportantTextColor,
      ),
    );
  }

  ColorScheme blastpinColorSheme(ColorScheme base){
    return base.copyWith(
      background: defBackgroundPrimaryColor,
      primary: defPrimaryColor,
      secondary: defBodyTextColor,
    );
  }

  //ThemeData
  final ThemeData blastpinTheme = ThemeData.dark();

  return blastpinTheme.copyWith(
    textTheme: blastpinTextTheme(blastpinTheme.textTheme),
    colorScheme: blastpinColorSheme(blastpinTheme.colorScheme),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
}

