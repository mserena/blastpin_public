import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

Future<DateTime?> showCustomDatePicker(BuildContext context, DateTime currentTime, DateTime minTime) async{
  return await DatePicker.showDatePicker(
    context,
    showTitleActions: true,
    minTime: minTime,
    maxTime: minTime.add(defMaxAnticipation),
    currentTime: currentTime,
    locale: LocaleType.es,
    theme: getDatePickerTheme()
  );
}

Future<DateTime?> showCustomTimePicker(BuildContext context, {DateTime? currentTime}) async{
  return await DatePicker.showTimePicker(
    context,
    showTitleActions: true,
    showSecondsColumn: false,
    currentTime: currentTime,
    locale: LocaleType.es,
    theme: getDatePickerTheme()
  );
}

  DatePickerTheme getDatePickerTheme(){
  return DatePickerTheme(
    backgroundColor: defBackgroundPrimaryColor,
    itemStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
    doneStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
    cancelStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!,
    doneText: LanguageManager().getText('Confirm'),
    cancelText: LanguageManager().getText('Cancel')
  );
}