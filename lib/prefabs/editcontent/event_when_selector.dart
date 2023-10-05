import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/prefabs/alerts/alert_dialog.dart';
import 'package:blastpin/prefabs/day_picker.dart';
import 'package:blastpin/prefabs/dropdown_button_box.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/datetime_picker.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EventWhenSelector extends StatefulWidget {
  final Function resfreshView;

  const EventWhenSelector({super.key, required this.resfreshView});

  @override
  State<EventWhenSelector> createState() => EventWhenSelectorState();
}

class EventWhenSelectorState extends State<EventWhenSelector> with AfterLayoutMixin<EventWhenSelector>{
  double _viewWidth = defMaxEditContentViewWidth;

  final GlobalKey<FormFieldState> _whenStartDateEventTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _whenStartDateEventTextController = TextEditingController();
  final GlobalKey<FormFieldState> _whenStartHourEventTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _whenStartHourEventTextController = TextEditingController();
  final GlobalKey<FormFieldState> _whenEndDateEventTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _whenEndDateEventTextController = TextEditingController();
  final GlobalKey<FormFieldState> _whenEndHourEventTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _whenEndHourEventTextController = TextEditingController();

  DateTime _whenStart = DateTime.now();
  DateTime _whenEnd = DateTime.now().add(const Duration(hours: 1));
  EventRepeat _eventRepeat = EventRepeat.unique;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    if(EditContentManager().getEditContent() != null){
      ContentEvent content = EditContentManager().getEditContent() as ContentEvent;
      bool changes = false;
      if(content.whenStart != null){
        _whenStart = content.whenStart!;
      } else {
        content.whenStart = _whenStart;
        changes = true;
      }
      if(content.whenEnd != null){
        _whenEnd = content.whenEnd!;
      } else {
        content.whenEnd = _whenEnd;
        changes = true;
      }
      _eventRepeat = (EditContentManager().getEditContent() as ContentEvent).repeat;
      if(changes){
        _updateContentDateTimes();
      } else {
        widget.resfreshView();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    _viewWidth = _viewWidth -20;
    _whenStartDateEventTextController.text = DateTimeUtils.getDateTimeFormatted(DateFormat('dd-MM-yyyy'), specificDateTime: _whenStart);
    _whenStartHourEventTextController.text = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(), specificDateTime: _whenStart);
    _whenEndDateEventTextController.text = DateTimeUtils.getDateTimeFormatted(DateFormat('dd-MM-yyyy'), specificDateTime: _whenEnd);
    _whenEndHourEventTextController.text = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(), specificDateTime: _whenEnd);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            createInputDataBox(
              textFormFieldKey: _whenStartDateEventTextFormFieldKey,
              textController: _whenStartDateEventTextController,
              textAlign: TextAlign.center,
              width: _viewWidth/2-40,
              readOnly: true,
              icon: FontAwesomeIcons.calendarDays,
              onPress: _onPressSelectDateEventStart,
            ),
            const SizedBox(width: 40),
            createInputDataBox(
              textFormFieldKey: _whenStartHourEventTextFormFieldKey,
              textController: _whenStartHourEventTextController,
              textAlign: TextAlign.center,
              width: _viewWidth/2-40,
              readOnly: true,
              icon: FontAwesomeIcons.clock,
              onPress: _onPressSelectTimeEventStart,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            createInputDataBox(
              textFormFieldKey: _whenEndDateEventTextFormFieldKey,
              textController: _whenEndDateEventTextController,
              textAlign: TextAlign.center,
              width: _viewWidth/2-40,
              readOnly: true,
              icon: FontAwesomeIcons.calendarDays,
              onPress: _onPressSelectDateEventEnd,
            ),
            const SizedBox(width: 40),
            createInputDataBox(
              textFormFieldKey: _whenEndHourEventTextFormFieldKey,
              textController: _whenEndHourEventTextController,
              textAlign: TextAlign.center,
              width: _viewWidth/2-40,
              readOnly: true,
              icon: FontAwesomeIcons.clock,
              onPress: _onPressSelectTimeEventEnd,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createDropdownButtonBox(
              options: EventRepeat.values,
              currentOption: _eventRepeat,
              width: _viewWidth/2-40,
              iconLeft: FontAwesomeIcons.repeat,
              onChanged: _onChangeRepeat
            ),
            const SizedBox(width: 40),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              width: _viewWidth/2-40,
              child: Text(
                TextUtils.getEventRepeatString(EditContentManager().getEditContent()! as ContentEvent),
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
              )
            ),
          ],
        ),
      ],
    );
  }

  void _onChangeRepeat(EventRepeat selectedRepeat) async{
    debugPrint('Selected repeat is $selectedRepeat');
    _eventRepeat = selectedRepeat;
    switch(selectedRepeat) {
      case EventRepeat.unique:
      case EventRepeat.daily:
      case EventRepeat.monthly:
      case EventRepeat.annually:
        EditContentManager().setEventRepeat(_eventRepeat);
        break;
      case EventRepeat.weekly:
        await _createWeeklyRepeatDialog();
        break;
    }
    _eventRepeat = (EditContentManager().getEditContent() as ContentEvent).repeat; 
    widget.resfreshView();
  }

  Future<void> _createWeeklyRepeatDialog() async{
    List<int>? selectedDays = (EditContentManager().getEditContent() as ContentEvent).repeatWeekDays;

    Widget daySelector = StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          width: _viewWidth,
          child: Column(
            children: [
              const SizedBox(height: 25),
              createDayPicker(
                (values) async{
                  await _onSelectDay(values);
                  setState(() {});
                },
                selectedDays: selectedDays,
              ),
              const SizedBox(height: 20),
              Text(
                TextUtils.getEventRepeatString(EditContentManager().getEditContent()! as ContentEvent),
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
              )
            ],
          ),
        );
      },
    );

    await createBasicAlert(
      context,
      title: LanguageManager().getText('Repeat'),
      closeButton: true,
      tapDismiss: true,
      content: daySelector
    ).show();
  }

  Future<void> _onSelectDay(List<String> values) async{
    await EditContentManager().setEventRepeat(_eventRepeat,repeatData: values);
  }

  void _onPressSelectDateEventStart() async{
    DateTime? response = await showCustomDatePicker(context,_whenStart,DateTime.now());
    if(response != null){
      setState(() {
        _whenStart = DateTime(response.year,response.month,response.day,_whenStart.hour,_whenStart.minute);
      });
      _updateContentDateTimes();
    }
  }

  void _onPressSelectDateEventEnd() async{
    DateTime? response = await showCustomDatePicker(context,_whenEnd,_whenStart);
    if(response != null){
      setState(() {
        _whenEnd = DateTime(response.year,response.month,response.day,_whenEnd.hour,_whenEnd.minute);
        _updateContentDateTimes();
      });
    }
  }

  void _onPressSelectTimeEventStart() async{
    DateTime? response = await showCustomTimePicker(context, currentTime: _whenStart);
    if(response != null){
      setState(() {
        _whenStart = DateTime(_whenStart.year,_whenStart.month,_whenStart.day,response.hour,response.minute);
        _updateContentDateTimes();
      });
    }
  }

  void _onPressSelectTimeEventEnd() async{
    DateTime? response = await showCustomTimePicker(context, currentTime: _whenEnd);
    if(response != null){
      setState(() {
        _whenEnd = DateTime(_whenEnd.year,_whenEnd.month,_whenEnd.day,response.hour,response.minute);
        _updateContentDateTimes();
      });
    }
  }

  Future<void> _updateContentDateTimes() async{
    if(EditContentManager().getEditContent() != null){
      bool changes = false;
      ContentEvent content = EditContentManager().getEditContent()! as ContentEvent;

      if(content.whenStart != _whenStart){
        content.whenStart = _whenStart;
        changes = true;
      }

      if(content.whenEnd != _whenEnd){
        content.whenEnd = _whenEnd;
        changes = true;
      }

      if(changes){
        await EditContentManager().storeEditContentDataLocal();
      }
      widget.resfreshView();
    }
  }
}