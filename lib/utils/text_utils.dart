import 'dart:ui';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

class TextUtils{
  static double getFontSize(ObjectSize size, {BuildContext? context}){
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
          return view == DeviceView.expanded ? 25 : 20;
        case ObjectSize.normal:
          return view == DeviceView.expanded ? 18 : 15;
        case ObjectSize.small:
          return view == DeviceView.expanded ? 15 : 12;
      }
    }
    return 0;
  }

  static bool validateEmail(String? value) {
    if(value != null){
      String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(value) || value.length > 320)
      {
        return false;
      }
      return true;
    }
    return false;
  }

  static bool validateUsername(String? value) {
    if(value != null){
      String pattern = r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$";
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(value) || value.length > 50)
      {
        return false;
      }
      return true;
    }
    return false;
  }

  static List<String?> captureStrings(String input) {
    var re = RegExp(r'==([^]*?)==');
    List<String?> match = re.allMatches(input).map((m) => m.group(0)).toList();
    return match;
  }

  static T? enumFromString<T>(Iterable<T> values, String value) {
    String enumString = value;
    if(value.contains('.')){
      enumString = enumString.split('.').last;
    }
    return values.firstWhereOrNull((type) => type.toString().split('.').last == enumString);
  }

  static String stringFromEnum<T>(T value){
    String valueStr = value.toString();
    return valueStr.split('.').last;
  }

  static bool containsNumbers(String str){
    return str.contains(RegExp(r'[0-9]'));
  }

  static String getEventRepeatString(ContentEvent event){
    String repeatString = '';
    if(event.whenStart != null && event.whenEnd != null){
      switch(event.repeat) {
        case EventRepeat.unique:
          repeatString = '';
          break;
        case EventRepeat.daily:
          repeatString = '${LanguageManager().getText('Occurs every day until')} ${DateTimeUtils.getDateTimeFormatted(DateFormat('dd-MM-yyyy'), specificDateTime: event.whenEnd)}.';
          break;
        case EventRepeat.weekly:
          if(event.repeatWeekDays != null){
            repeatString = '${LanguageManager().getText('Occurs every')} ';
            for(int idxDay = 0; idxDay < event.repeatWeekDays!.length; idxDay++){
              String dayStr = defWeekdays[event.repeatWeekDays![idxDay]];
              repeatString += LanguageManager().getText(dayStr);
              if(event.repeatWeekDays!.length >= 2 && idxDay == event.repeatWeekDays!.length-2){
                repeatString += ' ${LanguageManager().getText('and')} ';
              } else if(idxDay == event.repeatWeekDays!.length-1){
                repeatString += ' ';
              }
              else {
                repeatString += ', ';
              }
            }
            repeatString += '${LanguageManager().getText('until')} ${DateTimeUtils.getDateTimeFormatted(DateFormat('dd-MM-yyyy'), specificDateTime: event.whenEnd)}.';
          }
          break;
        case EventRepeat.monthly:
          repeatString = '${LanguageManager().getText('Occurs every')} ${event.whenStart!.day.toString()} ${LanguageManager().getText('until')} ${DateTimeUtils.getDateTimeFormatted(DateFormat('dd-MM-yyyy'), specificDateTime: event.whenEnd)}.';
          break;
        case EventRepeat.annually:
          repeatString = '${LanguageManager().getText('Occurs every')} ';
          repeatString += '${event.whenStart!.day.toString()} ';
          repeatString += '${LanguageManager().getText(defMonths[event.whenStart!.month-1])}.';
          break;
      }
    }
    return repeatString;
  }

  static bool parseBool(String boolStr){
    return boolStr.toLowerCase() == 'true' ? true : false;
  }

  static int getIntFromString(String numStr){
    int price = int.parse(numStr.replaceAll(RegExp(r'[^0-9]'),''));
    return price;
  }

  static List<String> getStringLines(String text, TextPainter textPainter, double width){
    List<String> strLines = [];
    textPainter.layout(maxWidth: width);
    List<LineMetrics> lines = textPainter.computeLineMetrics();
    for(int idxLine = 0; idxLine < lines.length; idxLine++){
      LineMetrics line = lines[idxLine];
      var startPosition = textPainter.getPositionForOffset(Offset(line.left, line.baseline));
      var endPosition = textPainter.getPositionForOffset(Offset(line.left + line.width, line.baseline));
      var substr = text.substring(startPosition.offset, endPosition.offset);
      strLines.add(substr);
    }
    return strLines;
  }
}