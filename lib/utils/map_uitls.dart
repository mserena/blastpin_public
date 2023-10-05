import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_utils;

class MapUtils{
  static List<LatLng> allMapPolygon(){
    double delta = 0.01;
    return <LatLng> [
      LatLng(90 - delta, -180 + delta),
      LatLng(0, -180 + delta),
      LatLng(-90 + delta, -180 + delta),
      LatLng(-90 + delta, 0),
      LatLng(-90 + delta, 180 - delta),
      LatLng(0, 180 - delta),
      LatLng(90 - delta, 180 - delta),
      LatLng(90 - delta, 0),
      LatLng(90 - delta, -180 + delta)
    ];
  }

  static Size getMarkerSize(ObjectSize size, {BuildContext? context}){
    BuildContext? currentContext;
    if(context != null){
      currentContext = context;
    } else if(gNavigatorStateKey.currentContext != null){
      currentContext = gNavigatorStateKey.currentContext;
    }

    if(currentContext != null){
      DeviceView view = DeviceManager().getDeviceView(currentContext);
      switch(size){
        case ObjectSize.big:
          return view == DeviceView.expanded ? const Size(75,75) : const Size(50,50);
        case ObjectSize.normal:
          return view == DeviceView.expanded ? const Size(50,50) : const Size(40,40);
        case ObjectSize.small:
          return view == DeviceView.expanded ? const Size(25,25) : const Size(15,15);
      }
    }
    return Size.zero;
  }

  static bool polygonContainsPoint(LatLng point, List<LatLng> polygon){
    map_utils.LatLng pointMapUtils = map_utils.LatLng(point.latitude,point.longitude);
    List<map_utils.LatLng> polygonMapUtils = [];
    for(int idxLine = 0; idxLine < polygon.length; idxLine++){
      polygonMapUtils.add(map_utils.LatLng(polygon[idxLine].latitude,polygon[idxLine].longitude));
    }
    bool contains = map_utils.PolygonUtil.containsLocation(pointMapUtils, polygonMapUtils, true);
    return contains;
  }

  static String? shortAddressFromGoogleAddressComponents(Iterable<GoogleGeocodingAddressComponent> addressComponents){
    String? route = addressComponents.firstWhereOrNull((element) => element.types.first == 'route')?.longName;
    String? streetNumber = addressComponents.firstWhereOrNull((element) => element.types.first == 'street_number')?.longName;
    String? shortAddress;
    if(route != null){
      shortAddress = route;
      if(streetNumber != null){
        shortAddress += ', $streetNumber';
      }
    }
    return shortAddress;
  }

  static String shortAddressFromLongAddress(String address){
    List<String> addressComponents = address.split(', ');
    String shortAddress = addressComponents.first;
    if(addressComponents.length > 1 && TextUtils.containsNumbers(addressComponents[1])){
      shortAddress += ', ${addressComponents[1]}';
    }
    return shortAddress;
  }
}