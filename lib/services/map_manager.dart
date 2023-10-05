import 'dart:convert';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/settings/map_settings.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/map_uitls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';

class MapManager{
  bool _initialized = false;
  late String _darkMapStyle;
  late MapSettings _mapSettings;
  late MapArea _currentMapArea;
  final Map<MapDisplayType,List<Marker>> _markers = <MapDisplayType,List<Marker>>{};
  final Map<MapDisplayType,List<Polygon>> _polygons = <MapDisplayType,List<Polygon>>{};

  // Singleton
  static final MapManager _instance = MapManager._internal();

  factory MapManager(){
    return _instance;
  }

  MapManager._internal();

  init() async{
    if(!_initialized)
    {
      // load map style
      _darkMapStyle = await rootBundle.loadString('assets/settings/maps/map_dark_style.json');

      // load map areas
      String jsonStringMapSettings = await rootBundle.loadString('assets/settings/maps/map_settings.json');
      Map<String, dynamic> jsonObjectMapSettings = jsonDecode(jsonStringMapSettings); 
      _mapSettings = MapSettings.fromJson(jsonObjectMapSettings);

      // load default map elements
      for (var viewType in MapDisplayType.values) {
        _polygons.putIfAbsent(viewType, () => _loadPolygons(viewType));

        List<Marker> viewMarkers = await _loadMarkers(viewType);
        _markers.putIfAbsent(viewType, () => viewMarkers);
      }

      // set initial current area
      _currentMapArea = _mapSettings.areas.firstWhere((area) => area.id == _mapSettings.defaultArea);

      _initialized = true;
    }
  }

  Future<List<Marker>> _loadMarkers(MapDisplayType viewType) async{
    List<Marker> markers = [];
    switch(viewType) {
      case MapDisplayType.empty:
        break;
      case MapDisplayType.cities: 
        for(int idxArea = 0; idxArea < _mapSettings.areas.length; idxArea++){
          BitmapDescriptor markerbitmap = await ImageUtils.createCustomMarkerImageTextBitmap(
            imagePath: _mapSettings.areas[idxArea].icon,
            imageSize: MapUtils.getMarkerSize(ObjectSize.big),
            text: _mapSettings.areas[idxArea].id,
            textStyle: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!
          );

          Marker marker = Marker(
            markerId: MarkerId(_mapSettings.areas[idxArea].id),
            position: _mapSettings.areas[idxArea].center,
            icon: markerbitmap,
          );

          markers.add(marker);
        }
        break;
      case MapDisplayType.events:
        // TODO: Get cloud events based on map area and filters
        break;
    }
    return markers;
  }

  List<Polygon> _loadPolygons(MapDisplayType viewType){
    List<Polygon> polygons = [];
    List<List<LatLng>> holes = [];

    if(viewType == MapDisplayType.events){
      for(int idxArea = 0; idxArea < _mapSettings.areas.length; idxArea++){
        List<LatLng> coordinates = _mapSettings.areas[idxArea].polygon;
        Polygon polygon = Polygon(
          polygonId: PolygonId(_mapSettings.areas[idxArea].id),
          strokeWidth: 2,
          strokeColor: defPrimaryColor,
          fillColor: Colors.transparent,
          points: coordinates,
        );
        polygons.add(polygon);
        holes.add(coordinates);
      }
    }

    Polygon polygonAllMap = Polygon(
      polygonId: const PolygonId(defPolygonAllMapId),
      strokeWidth: 0,
      fillColor: Colors.black.withOpacity(0.5),
      points: MapUtils.allMapPolygon(),
      holes: holes,
    );
    polygons.add(polygonAllMap);

    return polygons;
  }

  String getMapStyle(){
    return _darkMapStyle;
  }

  List<Polygon> getMapPolygons(MapDisplayType viewType){
    if(_polygons.containsKey(viewType)){
      return _polygons[viewType]!;
    }
    return [];
  }

  List<Marker> getMapMarkers(MapDisplayType viewType){
    if(_markers.containsKey(viewType)){
      return _markers[viewType]!;
    }
    return [];
  }

  LatLngBounds getMapBounds(){
    return _mapSettings.bounds;
  }

  MapArea getMapCurrentArea(){
    return _currentMapArea;
  }

  List<String> getAvailableAreas(){
    List<String> availableAreas = [];
    for(int idxArea = 0; idxArea < _mapSettings.areas.length; idxArea++){
      availableAreas.add(_mapSettings.areas[idxArea].id);
    }
    return availableAreas;
  }

  MapArea? getMapArea(String areaId){
    return _mapSettings.areas.firstWhereOrNull((area) => area.id == areaId);
  }

  void setMapPaused(bool paused){
    if(gMapDisplayViewStateKey.currentState != null){
      gMapDisplayViewStateKey.currentState!.setPaused(paused);
    }
  }

  Future<void> setMapDeviceLocation(LatLng deviceLocation) async{
    if(gMapDisplayViewStateKey.currentState != null){
      BitmapDescriptor markerBitmap;
      Marker? oldDeviceLocationMarker = _markers[MapDisplayType.events]!.firstWhereOrNull((marker) => marker.markerId == defDeviceLocationMarkerId);
      if(oldDeviceLocationMarker == null){
         markerBitmap = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              size: MapUtils.getMarkerSize(ObjectSize.normal),
            ),
            'assets/images/location/DeviceLocationIcon.png',
        );
      } else {
        markerBitmap = oldDeviceLocationMarker.icon;
        _markers[MapDisplayType.events]!.remove(oldDeviceLocationMarker);
      }
      Marker deviceLocationMarker = Marker(
        markerId: defDeviceLocationMarkerId,
        position: deviceLocation,
        icon: markerBitmap,
      );
      _markers[MapDisplayType.events]!.add(deviceLocationMarker);

      await gMapDisplayViewStateKey.currentState!.updateCurrentViewMarkers(moveToPosition: deviceLocation);
      debugPrint('Device position draw on map at ${deviceLocation.toString()}');
    }
  }

  bool isValidLocation(LatLng point){
    for(int idxArea = 0; idxArea < _mapSettings.areas.length; idxArea++){
      if(MapUtils.polygonContainsPoint(point, _mapSettings.areas[idxArea].polygon)){
        return true;
      }
    }
    return false;
  }
}