
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/prefabs/alerts/alert_dialog.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/social_link_utils.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Alert?> createAlertOpenSocialLink(BuildContext context, Uri toLaunch, String title, String value, String buttonTitle) async{
  double alertContentWidth = MediaQuery.of(context).size.width < defMaxButtonWidth ? MediaQuery.of(context).size.width : defMaxButtonWidth;
  alertContentWidth = alertContentWidth - 20;
  Widget button = Container();
  if(await canLaunchUrl(toLaunch)){
    button = Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: alertContentWidth,
          child: createButtonGeneric(
            buttonTitle,
            () async{
              await launchUrl(toLaunch);
            },
            backgroundColor: defPrimaryColor
          )
        ) 
      )
    );
  } 
  
  if(context.mounted){
    return createBasicAlert(
      context,
      title: LanguageManager().getText(title),
      desc: value,
      tapDismiss: true,
      closeButton: true,
      content: button,
    );
  } else {
    return null;
  }
}

Future<bool> openSocialLink(SocialLinkType type, Content content) async{
  try{
    BuildContext? currentContext = gNavigatorStateKey.currentContext;
    if(currentContext != null){
      switch(type) {
        case SocialLinkType.whatsapp:
          String whatsappUrl = 'whatsapp://send?phone=${content.socialLinks[type]!}';
          Uri toLaunch = Uri.parse(whatsappUrl);
          if (currentContext.mounted){
            Alert? popup = await createAlertOpenSocialLink(currentContext,toLaunch,'Watsapp',content.socialLinks[type]!,'Send Watsapp');
            if(popup != null){
              await popup.show();
            } else {
              return false;
            }
          } else {
            return false;
          }
          break;
        case SocialLinkType.telephone:
          Uri toLaunch = Uri(scheme: 'tel', path: content.socialLinks[type]!);
          if (currentContext.mounted){
            Alert? popup = await createAlertOpenSocialLink(currentContext,toLaunch,'Telephone',content.socialLinks[type]!,'Call');
            if(popup != null){
              await popup.show();
            } else {
              return false;
            }
          } else {
            return false;
          }
          break;
        case SocialLinkType.email:
          //TODO: not work on web, open a blank page.
          Uri toLaunch = Uri(
            scheme: 'mailto',
            path: content.socialLinks[type]!,
            query: SocialLinkUtils.encodeQueryParameters(<String, String>{
              'subject': content.getLanguageString(defContentLanguageTitleKey),
            }),
          );
          if (currentContext.mounted){
            Alert? popup = await createAlertOpenSocialLink(currentContext,toLaunch,'Email',content.socialLinks[type]!,'Send e-mail');
            if(popup != null){
              await popup.show();
            } else {
              return false;
            }
          } else {
            return false;
          }
          break;
        case SocialLinkType.website:
        case SocialLinkType.instagram:
        case SocialLinkType.tiktok:
        case SocialLinkType.youtube:
          Uri toLaunch = Uri.parse(content.socialLinks[type]!);
          if(await canLaunchUrl(toLaunch)){
            await launchUrl(toLaunch);
          } else {
            return false;
          }
      }
    } else {
      return false;
    }
  }catch(e){
    debugPrint('Exception when open social link: ${e.toString()}');
    return false;
  }
  return true;
}