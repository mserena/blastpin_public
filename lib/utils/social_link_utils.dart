import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/cloud_functions_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLinkUtils{
  static IconData getIcon(SocialLinkType type){
    switch(type) {
      case SocialLinkType.whatsapp:
        return FontAwesomeIcons.whatsapp;
      case SocialLinkType.telephone:
        return FontAwesomeIcons.phone;
      case SocialLinkType.email:
        return FontAwesomeIcons.at;
      case SocialLinkType.instagram:
        return FontAwesomeIcons.instagram;
      case SocialLinkType.tiktok:
        return FontAwesomeIcons.tiktok;
      case SocialLinkType.website:
        return FontAwesomeIcons.globe;
      case SocialLinkType.youtube:
        return FontAwesomeIcons.youtube;
    }
  }

  static String getHintText(SocialLinkType type){
    switch(type) {
      case SocialLinkType.telephone:
      case SocialLinkType.whatsapp:
        return 'Valid phone number (+34656611612)';
      case SocialLinkType.email:
        return 'Valid e-mail address (address@provider.com)';
      case SocialLinkType.instagram:
        return 'Valid Instagram profile (https://www.instagram.com/username)';
      case SocialLinkType.tiktok:
        return 'Valid TikTok profile (https://www.tiktok.com/@username)';
      case SocialLinkType.website:
        return 'Valid website url (https://www.google.com)';
      case SocialLinkType.youtube:
        return 'Valid Youtube channel or video (https://www.youtube.com/channel/channel_id)';
    }
  }

  static String getErrorTextNotValidFormat(SocialLinkType type){
    switch(type) {
      case SocialLinkType.telephone:
      case SocialLinkType.whatsapp:
        return 'Invalid phone number';
      case SocialLinkType.email:
        return 'Invalid e-mail address';
      case SocialLinkType.instagram:
      case SocialLinkType.tiktok:
      case SocialLinkType.website:
      case SocialLinkType.youtube:
        return 'Invalid URL format';
    }
  }

  static String getErrorTextNotOnline(SocialLinkType type){
    switch(type) {
      case SocialLinkType.telephone:
      case SocialLinkType.whatsapp:
      case SocialLinkType.email:
        return '';
      case SocialLinkType.instagram:
      case SocialLinkType.tiktok:
      case SocialLinkType.website:
      case SocialLinkType.youtube:
        return 'URL is not online.';
    }
  }

  static TextInputType getInputKeyboard(SocialLinkType type){
    switch(type) {
      case SocialLinkType.telephone:
      case SocialLinkType.whatsapp:
        return TextInputType.phone;
      case SocialLinkType.email:
        return TextInputType.emailAddress;
      case SocialLinkType.instagram:
      case SocialLinkType.tiktok:
      case SocialLinkType.website:
      case SocialLinkType.youtube:
        return TextInputType.url;
    }
  }

  static bool validateLinkFormat(SocialLinkType type, String link){
    bool validLink = false;
    if(link.isNotEmpty){
      RegExp? regExp;
      switch(type) {
        case SocialLinkType.telephone:
        case SocialLinkType.whatsapp:
          regExp = RegExp(r'^\+?\d{1,4}?\(?\d{1,3}?\)?\d{1,4}\d{1,4}\d{1,9}$');
          break;
        case SocialLinkType.email:
          regExp = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
          break;
        case SocialLinkType.website:
          regExp = RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$');
          break;
        case SocialLinkType.instagram:
          regExp = RegExp(r'^(?:https?:\/\/)?(?:www.)?instagram.com\/?([a-zA-Z0-9\.\_\-]+)?(\/?([p]+)?([reel]+)?([tv]+)?([stories]+)?\/([a-zA-Z0-9\-\_\.]+)\/?([0-9]+)?\/?(a-zA-Z0-9\.\_\-]+)?)$');
          break;
        case SocialLinkType.tiktok:
          regExp = RegExp(r'^(?:https?:)?\/\/(?:www\.)?tiktok\.com/@[^/]+/?(?![^\s])$');
          break;
        case SocialLinkType.youtube:
          regExp = RegExp(r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$');
          break;
      }
      validLink = regExp.hasMatch(link);
    }
    return validLink;
  }

  static Future<bool> validateLinkExist(SocialLinkType type, String link) async{
    bool linkExist = false;
    if(link.isNotEmpty){
      switch(type) {
        case SocialLinkType.telephone:
        case SocialLinkType.whatsapp:
        case SocialLinkType.email:
          linkExist = true;
          break;
        case SocialLinkType.website:
        case SocialLinkType.instagram:
        case SocialLinkType.tiktok:
        case SocialLinkType.youtube:
          var response = await CloudFunctionsManager().checkUrl(url: link);
          if(response != null && response.data != null && response.data['result'] != null){
            if(response.data['result'] == 'done' && response.data['online'] != null && response.data['code'] != null){
              bool online =  response.data['online'];
              int statusCode = response.data['code'];
              if(online && statusCode >= 200 && statusCode < 300){
                debugPrint('social link is valid');
                linkExist = true;
              }
            }
          }
          break;
      }
    }
    return linkExist;
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}