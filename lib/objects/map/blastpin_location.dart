import 'package:google_maps_flutter/google_maps_flutter.dart';

class BlastPinLocation {
  String googleId;
  LatLng locationLatLong;
  String locationString;
  String shortLocationString;

  BlastPinLocation(
    {
    required this.googleId, 
    required this.locationLatLong, 
    required this.locationString,
    required this.shortLocationString,
    }
  );

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = <String,dynamic>{};
    json.putIfAbsent('googleId', () => googleId);
    json.putIfAbsent('location_latitude', () => locationLatLong.latitude.toString());
    json.putIfAbsent('location_longitude', () => locationLatLong.longitude.toString());
    json.putIfAbsent('locationString', () => locationString);
    json.putIfAbsent('shortLocationString', () => shortLocationString);
    return json;
  }

  factory BlastPinLocation.fromJson(Map<String,dynamic> json){
    return BlastPinLocation(
      googleId: json['googleId'],
      locationLatLong: LatLng(double.parse(json['location_latitude']),double.parse(json['location_longitude'])),
      locationString: json['locationString'],
      shortLocationString: json['shortLocationString']
    );
  }

  @override
  String toString(){
    return 'Location with id $googleId ($locationLatLong): $shortLocationString ($locationString)';
  }
}