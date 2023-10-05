import 'dart:convert';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/properties/blastpin_opening_hours.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:flutter/material.dart';

class ContentPlace extends Content{
  //JSON variables
  List<BlastPinOpeningHours> openingHours = [];

  ContentPlace(String userId) : super(userId, ContentBlastPinType.place){
    debugPrint('Created ContentPlace');
  }

  @override
  void populateFromJson(Map<String,dynamic> json){
    if(json['datetime'] != null){
      Map<String,dynamic> jsonDateTime = jsonDecode(json['datetime']);
      if(jsonDateTime['openingHours'] != null){
        Iterable data = jsonDecode(jsonDateTime['openingHours']);
        openingHours = List<BlastPinOpeningHours>.from(data.map((model)=> BlastPinOpeningHours.fromJson(model)));
      }
    }
  }

  @override
  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = super.toJson();
    Map<String,dynamic> jsonDateTime = <String,dynamic>{};

    if(openingHours.isNotEmpty){
      jsonDateTime.putIfAbsent('openingHours', () => jsonEncode(openingHours));
    }

    json.putIfAbsent('datetime', () => jsonEncode(jsonDateTime));
    return json;
  }
}