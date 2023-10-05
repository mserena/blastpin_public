import 'dart:async';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/notification_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeviceManager{
  Position? _deviceLocation;
  StreamSubscription<Position>? _deviceLocationStream;

  // Singleton
  static final DeviceManager _instance = DeviceManager._internal();

  factory DeviceManager(){
    return _instance;
  }

  DeviceManager._internal();

  DeviceView getDeviceView(BuildContext context){ 
    if (getDeviceType() == DeviceType.web) {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;
      if (width > defMinExpandedViewWidth && height > defMinExpandedViewHeigth) {
        return DeviceView.expanded;
      }
    }
    
    // running on mobile
    return DeviceView.compact;
  }

  DeviceType getDeviceType(){
    return kIsWeb ? DeviceType.web : DeviceType.mobile;
  }

  Future<LatLng?> getDeviceLocation({bool force = false}) async{
    try{
      if(await Geolocator.isLocationServiceEnabled()){
        LocationPermission permission = await Geolocator.checkPermission();
        if(permission == LocationPermission.denied){
          permission = await Geolocator.requestPermission();
          if(permission == LocationPermission.denied){
            NotificationManager().addNotification(CustomNotificationType.locationDeneided);
            return null;
          }
        }

        if(permission == LocationPermission.deniedForever){
          NotificationManager().addNotification(CustomNotificationType.locationDeneidedForever);
          return null;
        }

        if(_deviceLocation == null || force){
          _deviceLocation = await Geolocator.getCurrentPosition();
          
          if(_deviceLocationStream == null){
            LocationSettings locationSettings = const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 100,
            );
            _deviceLocationStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
              debugPrint(position == null ? 'Get position Stream Update: Unknown' : 'Get position Stream Update: ${position.latitude.toString()}, ${position.longitude.toString()}');
              if(position != null){
                _deviceLocation = position;
              }
            });
          }
        }

        return LatLng(_deviceLocation!.latitude,_deviceLocation!.longitude);
      } else {
        NotificationManager().addNotification(CustomNotificationType.locationDisabled);
        return null;
      }
    }catch(e){
      debugPrint('error on getDeviceLocation: ${e.toString()}');
    }
    return null;    
  }

  Future<String?> getDistanceBetweenDeviceStr(LatLng position) async{
    String? distanceStr;
    if(_deviceLocation == null){
      await getDeviceLocation(force: true);
    }
    if(_deviceLocation != null){
      double distanceInMeters = Geolocator.distanceBetween(_deviceLocation!.latitude,_deviceLocation!.longitude,position.latitude,position.longitude);
      double distanceInKm = distanceInMeters * 0.001;
      if(distanceInKm < 1){
        distanceStr = LanguageManager().getText('less than 1 Km');
      } else {
        distanceStr = '${distanceInKm.truncate().toString()} Km';
      }
    }
    return distanceStr;
  }

  Future<void> openDeviceSettings() async {
    if(!await Geolocator.openAppSettings()){
      debugPrint('App settings can\'t be opened.');
    }
  }

  Future<void> openDeviceLocationSettings() async{
    if(!await Geolocator.openLocationSettings()){
      debugPrint('App location settings can\'t be opened.');
    }
  }
}