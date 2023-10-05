import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/properties/blastpin_opening_hours.dart';
import 'package:blastpin/objects/content/content_place.dart';
import 'package:blastpin/prefabs/datetime_picker.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PlaceWhenSelectorOption{
  final GlobalKey<FormFieldState> optionOpenPlaceTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController optionOpenPlaceTextController = TextEditingController();
  final GlobalKey<FormFieldState> optionClosePlaceTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController optionClosePlaceTextController = TextEditingController();
  DateTime? openTime;
  DateTime? closeTime;
}

class PlaceWhenSelector extends StatefulWidget {
  final Function resfreshView;

  const PlaceWhenSelector({super.key, required this.resfreshView});

  @override
  State<PlaceWhenSelector> createState() => _PlaceWhenSelector();
}

class _PlaceWhenSelector extends State<PlaceWhenSelector>{
  double _viewWidth = defMaxEditContentViewWidth;
  final List<PlaceWhenSelectorOption> _daysOpeningHours = [];

  @override
  void initState() {
    for(int idxDay = 0; idxDay < defWeekdays.length; idxDay++){
      _daysOpeningHours.add(PlaceWhenSelectorOption());
    }

    if(EditContentManager().getEditContent() != null){
      ContentPlace content = EditContentManager().getEditContent()! as ContentPlace;
      for(int idxDay = 0; idxDay < content.openingHours.length; idxDay++){
        PlaceWhenSelectorOption? option = _daysOpeningHours[defWeekdaysShort.indexOf(content.openingHours[idxDay].weekday)];
        option.openTime = content.openingHours[idxDay].openTime;
        option.closeTime = content.openingHours[idxDay].closeTime;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    _viewWidth = _viewWidth -20;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int idxDay = 0; idxDay < _daysOpeningHours.length; idxDay++) ...{
          _createDayOpeningHoursSelector(idxDay),
          const SizedBox(height: 30),
        }
      ],
    );
  }

  Widget _createDayOpeningHoursSelector(int idxDay){
    bool activeDay = _daysOpeningHours[idxDay].openTime != null && _daysOpeningHours[idxDay].closeTime != null;
    if(_daysOpeningHours[idxDay].openTime != null){
      _daysOpeningHours[idxDay].optionOpenPlaceTextController.text = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(), specificDateTime: _daysOpeningHours[idxDay].openTime);
    }
    if(_daysOpeningHours[idxDay].closeTime != null){
      _daysOpeningHours[idxDay].optionClosePlaceTextController.text = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(), specificDateTime: _daysOpeningHours[idxDay].closeTime);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            textAlign: TextAlign.center,
            defWeekdaysShort[idxDay],
            style: activeDay ? Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium! : Theme.of(gNavigatorStateKey.currentContext!).textTheme.labelMedium!,
          ),
        ),
        const SizedBox(width: 30),
        createInputDataBox(
          textFormFieldKey: _daysOpeningHours[idxDay].optionOpenPlaceTextFormFieldKey,
          textController: _daysOpeningHours[idxDay].optionOpenPlaceTextController,
          textAlign: TextAlign.center,
          width: _viewWidth/2-95,
          readOnly: true,
          icon: FontAwesomeIcons.clock,
          iconColor: _daysOpeningHours[idxDay].openTime != null ? defPrimaryColor : defDisabledTextColor,
          onPress: (){
            _onPressSelectOpenTime(idxDay);
          } 
        ),
        const SizedBox(width: 30),
        createInputDataBox(
          textFormFieldKey: _daysOpeningHours[idxDay].optionClosePlaceTextFormFieldKey,
          textController: _daysOpeningHours[idxDay].optionClosePlaceTextController,
          textAlign: TextAlign.center,
          width: _viewWidth/2-95,
          readOnly: true,
          icon: FontAwesomeIcons.clock,
          iconColor: _daysOpeningHours[idxDay].closeTime != null ? defPrimaryColor : defDisabledTextColor,
          onPress: (){
            _onPressSelectCloseTime(idxDay);
          } 
        ),
        const SizedBox(width: 30),
        MouseRegion(
          cursor: activeDay ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: () async{
              if(activeDay){
                _daysOpeningHours[idxDay].openTime = null;
                _daysOpeningHours[idxDay].closeTime = null;
                _daysOpeningHours[idxDay].optionOpenPlaceTextController.text = '';
                _daysOpeningHours[idxDay].optionClosePlaceTextController.text  = '';
                await _updateContentOpeningHours(idxDay);
                widget.resfreshView();
              }
            },
            child: SizedBox(
              width: 40,
              child: activeDay ? Icon(
                FontAwesomeIcons.trash,
                color: defPrimaryColor,
                size: ImageUtils.getIconSize(ObjectSize.normal),
              ) : Container(),
            ),
          )
        )
      ],
    );
  }

  void _onPressSelectOpenTime(int idxDay) async{
    DateTime currentTime = DateTime(1970,1,1,8,0);
    PlaceWhenSelectorOption option = _daysOpeningHours[idxDay];
    if(option.openTime != null){
      currentTime = option.openTime!;
    }
    DateTime? response = await showCustomTimePicker(context, currentTime: currentTime);
    if(response != null){
      option.openTime = DateTime(1970,1,1,response.hour,response.minute);
      await _updateContentOpeningHours(idxDay);
    }
  }

  void _onPressSelectCloseTime(int idxDay) async{
    DateTime currentTime = DateTime(1970,1,1,20,0);
    PlaceWhenSelectorOption option = _daysOpeningHours[idxDay];
    if(option.closeTime != null){
      currentTime = option.closeTime!;
    }
    DateTime? response = await showCustomTimePicker(context, currentTime: currentTime);
    if(response != null){
      option.closeTime = DateTime(1970,1,1,response.hour,response.minute);
      await _updateContentOpeningHours(idxDay);
    }
  }

  Future<void> _updateContentOpeningHours(int idxDay) async{
    if(EditContentManager().getEditContent() != null){
      PlaceWhenSelectorOption option = _daysOpeningHours[idxDay];
      bool completeOpeningHours = option.openTime != null && option.closeTime != null;
      String dayStr = defWeekdaysShort[idxDay];
      ContentPlace content = EditContentManager().getEditContent()! as ContentPlace;
      BlastPinOpeningHours? contentBPOpeningHours = content.openingHours.firstWhereOrNull((day) => day.weekday == dayStr);
      bool changes = false;
      if(completeOpeningHours){
        BlastPinOpeningHours newBPOpeningHours = BlastPinOpeningHours(weekday: dayStr, openTime: option.openTime!, closeTime: option.closeTime!);
        if(contentBPOpeningHours != null){
          if(contentBPOpeningHours.openTime != option.openTime || contentBPOpeningHours.closeTime != option.closeTime){
            contentBPOpeningHours = newBPOpeningHours;
            changes = true;
          }
        } else {
          content.openingHours.add(newBPOpeningHours);
          changes = true;
        }
      } else{
        if(contentBPOpeningHours != null){
          content.openingHours.remove(contentBPOpeningHours);
          changes = true;
        }
      }

      if(changes){
        await EditContentManager().storeEditContentDataLocal();
      }
      widget.resfreshView();
    }
  }
}