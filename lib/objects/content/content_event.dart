import 'dart:convert';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/material.dart';

class ContentEvent extends Content{
  //JSON variables
  DateTime? whenStart;
  DateTime? whenEnd;
  EventRepeat repeat = EventRepeat.unique;
  List<int>? repeatWeekDays;

  ContentEvent(String userId) : super(userId, ContentBlastPinType.event){
    debugPrint('Created ContentEvent');
  }

  @override
  void populateFromJson(Map<String,dynamic> json){
    if(json['datetime'] != null){
      Map<String,dynamic> jsonDateTime = jsonDecode(json['datetime']);

      if(jsonDateTime['whenStart'] != null){
        whenStart = DateTime.parse(jsonDateTime['whenStart']);
      }

      if(jsonDateTime['whenEnd'] != null){
        whenEnd = DateTime.parse(jsonDateTime['whenEnd']);
      }

      if(jsonDateTime['repeat'] != null){
        repeat = TextUtils.enumFromString(EventRepeat.values,jsonDateTime['repeat'])!;
      }

      if(jsonDateTime['repeatWeekDays'] != null){
        repeatWeekDays = jsonDecode(jsonDateTime['repeatWeekDays']).cast<int>();
      }
    }
  }

  @override
  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = super.toJson();
    Map<String,dynamic> jsonDateTime = <String,dynamic>{};
    
    if(whenStart != null){
      jsonDateTime.putIfAbsent('whenStart', () => whenStart!.toIso8601String());
    }

    if(whenStart != null){
      jsonDateTime.putIfAbsent('whenEnd', () => whenEnd!.toIso8601String());
    }

    jsonDateTime.putIfAbsent('repeat', () => repeat.toString());

    if(repeatWeekDays != null){
      jsonDateTime.putIfAbsent('repeatWeekDays', () => jsonEncode(repeatWeekDays));
    }

    json.putIfAbsent('datetime', () => jsonEncode(jsonDateTime));
    return json;
  }
}