import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapArea{
  final String id;
  final String currency;
  final String locale;
  final String icon;
  final LatLng center;
  final LatLngBounds bounds;
  final List<LatLng> polygon;

  MapArea({required this.id, required this.currency, required this.locale, required this.icon, required this.center, required this.bounds, required this.polygon});

  factory MapArea.fromJson(Map<String, dynamic> data) {
    final String id = data['id'] as String;
    final String currency = data['currency'] as String;
    final String locale = data['locale'] as String;
    final String icon = data['icon'] as String;
    final LatLng center = LatLng(data['center']['latitude'],data['center']['longitude']);
    final LatLng southwest = LatLng(data['bounds']['southwest']['latitude'],data['bounds']['southwest']['longitude']);
    final LatLng northeast = LatLng(data['bounds']['northeast']['latitude'],data['bounds']['northeast']['longitude']);
    final LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    final List<dynamic> polygonData = data['polygon'] as List<dynamic>;
    final List<LatLng> polygon = polygonData.map((coordinates) => LatLng(coordinates['latitude'],coordinates['longitude'])).toList();
    return MapArea(id: id, currency: currency, locale: locale, icon: icon, center: center, bounds: bounds, polygon: polygon);
  }
}

class MapSettings{
  final LatLngBounds bounds;
  final String defaultArea;
  final List<MapArea> areas;
  
  MapSettings({required this.bounds, required this.defaultArea, required this.areas});
  
  factory MapSettings.fromJson(Map<String, dynamic> data) {
    final LatLng southwest = LatLng(data['bounds']['southwest']['latitude'],data['bounds']['southwest']['longitude']);
    final LatLng northeast = LatLng(data['bounds']['northeast']['latitude'],data['bounds']['northeast']['longitude']);
    final LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    final String defaultArea = data['defaultArea'];
    final List<dynamic> areasData = data['areas'] as List<dynamic>;
    final List<MapArea> areas = areasData.map((areaData) => MapArea.fromJson(areaData)).toList();
    return MapSettings(bounds: bounds, defaultArea: defaultArea, areas: areas);
  }
}