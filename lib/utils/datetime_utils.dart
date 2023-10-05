import 'dart:async';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateTimeUtils{
  static Future waitWhile(bool Function() validation, [Duration pollInterval = Duration.zero]) {
    var completer = Completer();
    check() {
      if (validation()) {
        completer.complete();
      } else {
        Timer(pollInterval, check);
      }
    }
    check();
    return completer.future;
  }

  static Future waitDuration(Duration time) async{
    await Future.delayed(time);
  }

  static String getDateTimeFormatted(DateFormat formatter, {Duration? addTime, DateTime? specificDateTime}){
    var dateTime = specificDateTime ?? DateTime.now();
    if(addTime != null){
      dateTime = dateTime.add(addTime);
    }
    String formattedDate = formatter.format(dateTime);
    return formattedDate;
  }

  static Future<String> getDateTimeFormattedLocale(DateTime dateTime) async{
    String currentLanguage = LanguageManager().getCurrentLanguage();
    await initializeDateFormatting(currentLanguage);
    String date = DateTimeUtils.getDateTimeFormatted(DateFormat.MMMEd(currentLanguage),specificDateTime: dateTime).toCapitalized();
    String time = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(), specificDateTime: dateTime);
    return '$date, $time';
  }

  static Widget buildDateTimeWithStyle(DateTime datetime, TextStyle style, {TextOverflow? overflow}){
    return FutureBuilder<String>(
      future: DateTimeUtils.getDateTimeFormattedLocale(datetime),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Text(
            snapshot.data!,
            style: style,
            overflow: overflow,
          );
        } else {
          return Container();
        }
      }
    );
  }
}