import 'dart:async';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/prefabs/map/map_view.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDisplayView extends MapView {
  const MapDisplayView(    
    {
      required key,
      required canInitializeMap,
      required double width,
      required double height,
      LatLng? initialLatLng,
      double? initialZoomLevel
    }
  ) : super(
    key: key,
    canInitializeMap: canInitializeMap,
    width: width,
    height: height,
    initialLatLng: initialLatLng,
    initialZoomLevel: initialZoomLevel
  );

  @override
  MapDisplayViewState createState() => MapDisplayViewState();
}

class MapDisplayViewState extends MapViewState<MapDisplayView>{
  MapDisplayType _currentMapDisplayType = MapDisplayType.empty;
  
  @override
  Future<void> onCameraMove(CameraPosition position) async{
    // zoom display type control
    if(position.zoom != currentCameraPosition.zoom){
      if(currentCameraPosition.zoom  <= defCitiesZoom){
         _updateMapView(MapDisplayType.cities);
      } else {
        _updateMapView(MapDisplayType.events);
      }
    }

    await super.onCameraMove(position);
  }

  void _updateMapView(MapDisplayType newMapView){
    if(_currentMapDisplayType != newMapView){
      _currentMapDisplayType = newMapView;
      setState(() {
        currentPolygons = MapManager().getMapPolygons(_currentMapDisplayType);
        currentMarkers = MapManager().getMapMarkers(_currentMapDisplayType);
      });
    }
  }

  Future<void> updateCurrentViewMarkers({LatLng? moveToPosition}) async{
    if(moveToPosition != null){
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: defOnMoveToPointMapZoom,
            target: moveToPosition
          )
        )
      );
    }

    setState(() {
      currentMarkers = MapManager().getMapMarkers(_currentMapDisplayType);
    }); 
  }

  @override
  Future<void> onMapCreated(GoogleMapController controller) async{
    await super.onMapCreated(controller);
    currentPolygons = MapManager().getMapPolygons(MapDisplayType.events);
  }
}