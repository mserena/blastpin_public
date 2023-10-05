import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/authentification_manager.dart';
import 'package:blastpin/services/cloud_functions_manager.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/content/content_manager.dart';
import 'package:blastpin/services/currency_manager.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/local_storage_manager.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/services/notification_manager.dart';
import 'package:blastpin/services/package_info_manager.dart';
import 'package:blastpin/services/tags_manager.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class ServicesLoader{
  bool _servicesLoaded = false;
  bool _loadingServices = false;

  // Singleton
  static final ServicesLoader _instance = ServicesLoader._internal();

  factory ServicesLoader(){
    return _instance;
  }

  ServicesLoader._internal();

  Future<void> loadServices({useFirebaseEmulator = false}) async{
    if(!_servicesLoaded && !_loadingServices){
      _loadingServices = true;
      debugPrint('Services loader start.');

      try{
        await LocalStorageManager().init(clear: false);
      }catch(e){
        debugPrint('Error loading services LocalStorageManager: ${e.toString()}');
      }

      try{
        await PackageInfoManager().init();
      }catch(e){
        debugPrint('Error loading services PackageInfoManager: ${e.toString()}');
      }

      try{
        if(useFirebaseEmulator){
          try{
            FirebaseFunctions.instance.useFunctionsEmulator('localhost',5001);
          } catch(e) {
            debugPrint('Error on firebase emulator functions: ${e.toString()}');
          }

          try{
            //TODO: Can't use auth emulator because a random failure when try to init
            await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
          } catch(e) {
            // Flutter bug report https://github.com/firebase/flutterfire/pull/9601
            debugPrint('Error on firebase emulator auth (https://github.com/firebase/flutterfire/pull/9601): ${e.toString()}');
          }

          try{
            await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
          }catch(e) {
            debugPrint('Error on firebase emulator storage: ${e.toString()}');
          }
        }
        //Firebase functions test
        var response = await CloudFunctionsManager().getServerTime();
        if(response != null && response.data != null && response.data['serverTime'] != null){
          debugPrint('Firebase loaded! server time: ${response.data['serverTime']}');
        }
      }catch(e){
        debugPrint('Error loading services Firebase: ${e.toString()}');
      }

      try{
        if (DeviceManager().getDeviceType() == DeviceType.web) {
          //Initialiaze the facebook javascript SDK
          await FacebookAuth.instance.webAndDesktopInitialize(
            appId: "883491029607543",
            cookie: true,
            xfbml: true,
            version: "v14.0",
          );
        }
      }catch(e){
        debugPrint('Error loading services Facebook SDK Web: ${e.toString()}');
      }

      try{
        await AuthentificationManager().init();
      }catch(e){
        debugPrint('Error loading services AuthentificationManager: ${e.toString()}');
      }

      try{
        await LanguageManager().init();
      }catch(e){
        debugPrint('Error loading services LanguageManager: ${e.toString()}');
      }

      try{
        await MapManager().init();
      }catch(e){
        debugPrint('Error loading services MapManager: ${e.toString()}');
      }

      try{
        await NotificationManager().init();
      }catch(e){
        debugPrint('Error loading services NotificationManager: ${e.toString()}');
      }

      try{
        await TagsManager().init();
      }catch(e){
        debugPrint('Error loading services TagsManager: ${e.toString()}');
      }

      try{
        CurrencyManager().init();
      }catch(e){
        debugPrint('Error loading services CurrencyManager: ${e.toString()}');
      }

      try{
        await EditContentManager().init();
      }catch(e){
        debugPrint('Error loading services EditContentManager: ${e.toString()}');
      }    

      //Upload content test
      /*try{
        await EditContentManager().publish();
      }catch(e){
        debugPrint('Error on upload test: ${e.toString()}');
      }*/

      try{
        ContentManager().init();
      }catch(e){
        debugPrint('Error loading services ContentManager: ${e.toString()}');
      }

      debugPrint('Services loader finished.');
      _servicesLoaded = true;
      _loadingServices = false;
    }
  }

  bool isServicesLoaded(){
    return _servicesLoaded;
  }
}