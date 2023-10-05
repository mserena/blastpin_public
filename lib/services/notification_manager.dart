import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/settings/notifications_settings.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/user_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationManager{
  bool _initialized = false;
  late CustomNotificationsSettings _settings;
  final List<CustomNotificationType> _notifications = [];
  Flushbar? _currentNotification;

  // Singleton
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager(){
    return _instance;
  }

  NotificationManager._internal();

  init() async{
    if(!_initialized)
    {
      String jsonStringNotificationsSettings = await rootBundle.loadString('assets/settings/notifications_settings.json');
      Map<String, dynamic> jsonObjectNotificationsSettings = jsonDecode(jsonStringNotificationsSettings); 
      _settings = CustomNotificationsSettings.fromJson(jsonObjectNotificationsSettings);

      _initialized = true;
    }
  }

  void addNotification(CustomNotificationType type){
    if(!_notifications.contains(type)){
      CustomNotification? newNotification = _settings.notifications.firstWhereOrNull((notification) => notification.type == type);
      if(newNotification != null){
        _notifications.add(type);
        _showNextNotification();
      }
    }
  }

  Future<void> cleanNotifications({CustomNotificationType? type}) async{
    if(_notifications.isNotEmpty){
      if(type == null){
        _notifications.clear();
        if(_currentNotification != null){
          await _currentNotification!.dismiss();
        }
      } else {
        CustomNotificationType currentNotificationType = _notifications.first;
        if(_currentNotification != null && currentNotificationType == type){
          await _currentNotification!.dismiss();
        } else {
          _notifications.removeWhere((notificationType) => notificationType == type);
        }
      }
    }
  }

  void _showNextNotification(){
    if(_notifications.isNotEmpty && !isShowingNotification()){
      _show(_notifications.first);
    }
  }

  void _show(CustomNotificationType type){
    if(gNavigatorStateKey.currentContext != null){
      CustomNotification? newNotification = _settings.notifications.firstWhereOrNull((notification) => notification.type == type);
      if(newNotification != null){
        _currentNotification = Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(20, defTopBarHeigth, 20, 0),
          padding: const EdgeInsets.all(0),
          duration: newNotification.time == 0 ? null : const Duration(seconds: 3),
          isDismissible: false,
          animationDuration: const Duration(milliseconds: 500),
          flushbarStyle: FlushbarStyle.FLOATING,
          onTap: (flushBar) async {
            switch(newNotification.type){
              case CustomNotificationType.connectionError:
              case CustomNotificationType.locationDeneided:
              case CustomNotificationType.signinCheckEmailLink:
              case CustomNotificationType.signinDone:
              case CustomNotificationType.signinCanceled:
              case CustomNotificationType.signinError:
              case CustomNotificationType.publishDone:
              case CustomNotificationType.publishError:
              case CustomNotificationType.unknownError:
              case CustomNotificationType.unknown:
                break;
              case CustomNotificationType.locationDisabled:
                await DeviceManager().openDeviceLocationSettings();
                break;
              case CustomNotificationType.locationDeneidedForever:
                await DeviceManager().openDeviceSettings();
                break;
            }

            if(newNotification.time != 0){
              flushBar.dismiss();
            }
          },
          onStatusChanged: (status) {
            if(status != null){
              switch(status) {
                case FlushbarStatus.SHOWING:
                case FlushbarStatus.IS_APPEARING:
                case FlushbarStatus.IS_HIDING:
                  {
                    break;
                  }
                case FlushbarStatus.DISMISSED:
                  {
                    _currentNotification = null;
                    if(_notifications.isNotEmpty){
                      _notifications.removeAt(0);
                    }
                    _showNextNotification();
                    break;
                  }
              }
            }
          },
          messageText: Center(
            child: Container(
              decoration: BoxDecoration(
                color: defPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                _completeNotificationText(newNotification.text),
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
              )
            ),
          ),
        );
        _currentNotification!.show(gNavigatorStateKey.currentContext!);
      }
    }
  }

  String _completeNotificationText(String text){
    String newText = text;
    List<String?> patterns = TextUtils.captureStrings(text);
    for(int idxPattern = 0; idxPattern < patterns.length; idxPattern++){
      String? currentPattern = patterns[idxPattern];
      if(currentPattern != null){
        switch(currentPattern){
          case '==username==':{
            if(UserManager().isSignedIn() && UserManager().getUsername() != null){
              newText = newText.replaceAll('==username==', UserManager().getUsername()!);
            } else {
              newText = newText.replaceAll('==username==','');
            }
          }
          break;
        }
      }
    }
    return newText;
  }

  bool isShowingNotification(){
    return _currentNotification != null;
  }
}