import 'dart:async';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapView extends StatefulWidget {
  final double width;
  final double height;
  final Future canInitializeMap;
  final LatLng? initialLatLng;
  final double? initialZoomLevel;

  const MapView({required super.key, required this.canInitializeMap, required this.width, required this.height, this.initialLatLng, this.initialZoomLevel});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState<T extends MapView> extends State<T>{
  bool _pauseMap = false;
  late GoogleMapController googleMapController;
  bool googleMapLoaded = false;
  List<Polygon> currentPolygons = [];
  List<Marker> currentMarkers = [];
  late CameraPosition currentCameraPosition;
  MapGesture currentMapGesture = MapGesture.tap;
  Widget markerInfoWidget = Container();
  
  @override
  void initState() {
    currentCameraPosition = CameraPosition(
      target: widget.initialLatLng ?? MapManager().getMapCurrentArea().center,
      zoom: widget.initialZoomLevel ?? defDefaultMapZoom,
    );
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onVerticalDragStart: (start) {
        currentMapGesture = MapGesture.move;
      },
      child: Listener(
        onPointerSignal: (pointerSignal){
          if(pointerSignal is PointerScrollEvent){
            currentMapGesture = MapGesture.scale;
            GestureBinding.instance.pointerSignalResolver.register(pointerSignal,
              (PointerSignalEvent event){}
            );
          }
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              FutureBuilder(
                future: widget.canInitializeMap,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AnimatedOpacity(
                      opacity: googleMapLoaded ? 1 : 0.01,
                      duration: const Duration(milliseconds: 600),
                      child: AbsorbPointer(
                        absorbing: _pauseMap,
                        child: GoogleMap(
                          //gestureRecognizers: {                 
                            //Factory<OneSequenceGestureRecognizer>(
                            //  () => EagerGestureRecognizer()
                            //),
                          //},
                          myLocationEnabled: false,
                          mapToolbarEnabled: false,
                          zoomControlsEnabled: false,
                          minMaxZoomPreference: const MinMaxZoomPreference(5,19),
                          mapType: MapType.normal, 
                          initialCameraPosition: currentCameraPosition,
                          polygons: Set<Polygon>.of(currentPolygons),
                          markers: Set<Marker>.of(currentMarkers),
                          onMapCreated: onMapCreated,
                          onCameraMove: onCameraMove,
                          onCameraIdle: onCameraMoveFinished,
                          onCameraMoveStarted: onCameraMoveStarted,
                        ),
                      )
                    );
                  } else {
                    return Container();
                  }
                }
              ),
              if(!googleMapLoaded) ...{
                Container(
                  width: widget.width,
                  height: widget.height,
                  color: defWidgetLoadingColor,
                  child: createLoadingIndicator(),
                ),
              } else ...{
                markerInfoWidget,
              },
              PointerInterceptor(
                intercepting: _pauseMap,
                child: Container(
                )
              )
            ],
          )
        )
      )
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async{
    googleMapController = controller;
    await googleMapController.setMapStyle(MapManager().getMapStyle());
    onCameraMove(currentCameraPosition);
    debugPrint('Google Map with id ${googleMapController.mapId} created.');
    Future.delayed(
      const Duration(milliseconds: 600),
      () {
        setState(() {
          googleMapLoaded = true;
        });
      }
    );
  }

  Future<void> onCameraMoveStarted() async {
  }

  Future<void> onCameraMove(CameraPosition position) async{
    try{
      currentCameraPosition = position;
      // bounds control
      if(!MapManager().getMapBounds().contains(position.target)){
        googleMapController.moveCamera(CameraUpdate.newLatLngBounds(
          MapManager().getMapBounds(),
          10
        ));
      }
    }catch(e){
      debugPrint('Error onCameraMove ${e.toString()}');
    }

  }

  Future<void> onCameraMoveFinished() async {
  }

  void setPaused(bool pause){
    setState(() {
      _pauseMap = pause;
    });
  }

  void addSingleMarkerToPosition(BitmapDescriptor bitmap, LatLng position){
    try{
      //debugPrint('Add marker on google maps to position ${position.toString()}');
      Marker markerLocationFly = Marker(
        markerId: const MarkerId('location'),
        position: position,
        icon: bitmap,
        onTap: () {
          debugPrint('onTap marker');
        }
      );

      setState(() {
        currentMarkers = [markerLocationFly];
      });
    } catch(e){
      debugPrint('Error on _addMarkerToPosition ${e.toString()}');
    }
  }
}