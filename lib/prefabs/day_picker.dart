import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:day_picker/day_picker.dart';
import 'package:flutter/material.dart';

Widget createDayPicker(Function onSelectDay, {List<int>? selectedDays}){
  List<DayInWeek> selectableDays = [];
  for(int idxDay = 0; idxDay < defWeekdaysShort.length; idxDay++){
    bool selected = selectedDays != null && selectedDays.contains(idxDay);
    selectableDays.add(
      DayInWeek(
        defWeekdaysShort[idxDay],
        dayKey: defWeekdaysShort[idxDay],
        isSelected: selected
      )
    );
  }

  return SelectWeekDays(
    onSelect: onSelectDay,
    days: selectableDays,
    fontSize: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!.fontSize,
    selectedDayTextColor: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!.color,
    unSelectedDayTextColor: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!.color,
    selectedDaysFillColor: defPrimaryColor,
    unSelectedDaysFillColor: defBodyTextColor,
    backgroundColor: defBackgroundPrimaryColor,
    border: false,
    padding: 5,
    paddingDay: 10,
  );
}