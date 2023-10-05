import 'package:blastpin/utils/datetime_utils.dart';
import 'package:intl/intl.dart';

class BlastPinOpeningHours {
  String weekday;
  DateTime openTime;
  DateTime closeTime;

  BlastPinOpeningHours(
    {
    required this.weekday, 
    required this.openTime, 
    required this.closeTime,
    }
  );

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = <String,dynamic>{};
    json.putIfAbsent('weekday', () => weekday);
    json.putIfAbsent('openTime', () => openTime.toIso8601String());
    json.putIfAbsent('closeTime', () => closeTime.toIso8601String());
    return json;
  }

  factory BlastPinOpeningHours.fromJson(Map<String,dynamic> json){
    return BlastPinOpeningHours(
      weekday: json['weekday'],
      openTime: DateTime.parse(json['openTime']),
      closeTime: DateTime.parse(json['closeTime']),
    );
  }

  @override
  String toString(){
    String from = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(),specificDateTime: openTime);
    String to = DateTimeUtils.getDateTimeFormatted(DateFormat.Hm(),specificDateTime: closeTime);
    return '$weekday form $from to $to';
  }
}