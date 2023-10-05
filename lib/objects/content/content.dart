import 'dart:convert';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/objects/content/content_place.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket_free.dart';
import 'package:blastpin/objects/content/view/content_event_view.dart';
import 'package:blastpin/objects/content/view/content_place_view.dart';
import 'package:blastpin/objects/content/view/content_view.dart';
import 'package:blastpin/objects/map/blastpin_location.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:disposer/disposer.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class Content with Disposable{
  //JSON variables
  String? id;
  ContentBlastPinType type;
  ContentBlastPinStatus status;
  String userId;
  Map<String,Map<String,String>> languages = <String,Map<String,String>>{};
  List<String> mediaUrls = [];
  BlastPinLocation? location;
  String? mainTag;
  List<String> extraTags = [];
  Map<SocialLinkType,String> socialLinks = <SocialLinkType,String>{};
  BlastPinTicket ticket = BlastPinTicketFree();
  
  //Deploy variables
  List<XFile> media = [];

  Content(
    this.userId,
    this.type,
    {
      this.status = ContentBlastPinStatus.creating,
      Map<String,Map<String,String>>? languages,
      List<String>? mediaUrls,
      this.location,
      this.mainTag,
      List<String>? extraTags,
      Map<SocialLinkType,String>? socialLinks,
      BlastPinTicket? ticket,
    }
  ){
    this.mediaUrls = mediaUrls ?? [];
    this.languages = languages ?? <String,Map<String,String>>{};
    this.extraTags = extraTags ?? [];
    this.socialLinks = socialLinks ?? <SocialLinkType,String>{};
    this.ticket = ticket ?? BlastPinTicketFree();
  }

  @override
  void dispose() {
    debugPrint('Content disposed');
    super.dispose();
  }

  factory Content.fromJson(Map<String,dynamic> json){
    String userId = '';
    if(json['userId'] != null){
      userId = json['userId'];
    }

    ContentBlastPinType type = TextUtils.enumFromString(ContentBlastPinType.values,json['type'])!;
    Content fromJsonContent;
    switch(type) {
      case ContentBlastPinType.event:
        fromJsonContent = ContentEvent(userId);
        break;
      case ContentBlastPinType.place:
        fromJsonContent = ContentPlace(userId);
        break;
    }
    fromJsonContent.populateFromJson(json);

    if(json['id'] != null){
      fromJsonContent.id = json['id'];
    }

    if(json['status'] != null){
      fromJsonContent.status = TextUtils.enumFromString(ContentBlastPinStatus.values,json['status'])!;
    }

    Map<String,Map<String,String>> languages = <String,Map<String,String>>{};
    if(json['languages'] != null){
      Map<String,dynamic> jsonLanguages = jsonDecode(json['languages']);
      jsonLanguages.forEach((key,value){
        Map<String,String> languageData = <String,String>{};
        value.forEach((key, value) => languageData[key] = value.toString());
        languages.putIfAbsent(key, () => languageData);
      }); 
    }
    fromJsonContent.languages = languages;

    //TODO: read mediaUrls

    //TODO: deploy function to download media files

    if(json['location'] != null){
      Map<String,dynamic> jsonLocation = jsonDecode(json['location']);
      fromJsonContent.location = BlastPinLocation.fromJson(jsonLocation);
    }

    if(json['mainTag'] != null){
      fromJsonContent.mainTag = json['mainTag'];
    }

    if(json['extraTags'] != null){
      fromJsonContent.extraTags = jsonDecode(json['extraTags']).cast<String>();
    }

    Map<SocialLinkType,String> socialLinks = <SocialLinkType,String>{};
    if(json['socialLinks'] != null){
      Map<String,dynamic> jsonSocialLinks = jsonDecode(json['socialLinks']);
      jsonSocialLinks.forEach((key,value){
        SocialLinkType? type = TextUtils.enumFromString(SocialLinkType.values, key);
        if(type != null){
          socialLinks.putIfAbsent(type, () => value.toString());
        }
      }); 
    }
    fromJsonContent.socialLinks = socialLinks;

    if(json['ticket'] != null){
      fromJsonContent.ticket = BlastPinTicket.fromJson(jsonDecode(json['ticket']));
    }

    return fromJsonContent;
  }

  void populateFromJson(Map<String,dynamic> json){

  }

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = <String,dynamic>{};
    
    if(id != null){
      json.putIfAbsent('id', () => id);
    }

    json.putIfAbsent('userId', () => userId);

    json.putIfAbsent('type', () => type.toString());

    json.putIfAbsent('status', () => status.toString());

    if(languages.isNotEmpty){
      String languagesJson = jsonEncode(languages);
      json.putIfAbsent('languages', () => languagesJson);
    }

    if(mediaUrls.isNotEmpty){
      String mediaUrlsJson = jsonEncode(mediaUrls);
      json.putIfAbsent('mediaUrls', () => mediaUrlsJson);
    }

    if(location != null){
      String locationJson = jsonEncode(location!.toJson());
      json.putIfAbsent('location', () => locationJson);
    }

    if(mainTag != null){
      json.putIfAbsent('mainTag', () => mainTag);
    }

    if(extraTags.isNotEmpty){
      String extraTagsJson = jsonEncode(extraTags);
      json.putIfAbsent('extraTags', () => extraTagsJson);
    }

    if(socialLinks.isNotEmpty){
      Map<String,String> socialLinksEncode = <String,String>{};
      socialLinks.forEach((key,value){
        socialLinksEncode.putIfAbsent(TextUtils.stringFromEnum(key), () => value);
      });
      String socialLinksJson = jsonEncode(socialLinksEncode);
      json.putIfAbsent('socialLinks', () => socialLinksJson);
    }

    json.putIfAbsent('ticket', () => jsonEncode(ticket.toJson()));

    return json;
  }

  bool haveData(){
    if(
      id != null && id!.isNotEmpty ||
      languages.isNotEmpty ||
      mediaUrls.isNotEmpty ||
      media.isNotEmpty ||
      location != null ||
      mainTag != null ||
      extraTags.isNotEmpty ||
      socialLinks.isNotEmpty
    ){
      return true;
    }
    return false;
  }

  ContentView createView(Key key, double width){
    switch(type) {
      case ContentBlastPinType.event:
        return ContentEventView(key: key, content: this, width: width);
      case ContentBlastPinType.place:
        return ContentPlaceView(key: key, content: this, width: width);
    }
  }

  String getLanguageString(String key){
    String value = key;
    String currentLanguage = LanguageManager().getCurrentLanguage();
    Map<String,String> currentLanguageDefinitions = <String,String>{};
    if(languages.isNotEmpty){
      if(languages.containsKey(currentLanguage)){
        currentLanguageDefinitions = languages[currentLanguage]!;
      } else if(languages.containsKey(defDefaultLanguage)){
        currentLanguageDefinitions = languages[defDefaultLanguage]!;
      } else {
        currentLanguageDefinitions = languages[languages.keys.first]!;
      }

      if(currentLanguageDefinitions.containsKey(key)){
        value = currentLanguageDefinitions[key]!;
      }
    }
    return value;
  }
}