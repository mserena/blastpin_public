import 'dart:async';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/map/blastpin_location.dart';
import 'package:blastpin/objects/map/map_custom_info_window.dart';
import 'package:blastpin/prefabs/map/map_view.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:blastpin/utils/map_uitls.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clippy_flutter/triangle.dart';

class MapPickerView extends MapView {
  final Function? onSetMapLocation;
  final BlastPinLocation? initialBPLocation;

  const MapPickerView(
    {
      required key,
      required canInitializeMap,
      required double width,
      required double height,
      LatLng? initialLatLng,
      double? initialZoomLevel,
      this.onSetMapLocation,
      this.initialBPLocation
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
  MapPickerViewState createState() => MapPickerViewState();
}

class MapPickerViewState extends MapViewState<MapPickerView>{
  late final BitmapDescriptor _markerBitmapLocation;
  late final BitmapDescriptor _markerBitmapLocationFly;
  final _googleGeocodingApi = GoogleGeocodingApi(defGoogleMapsApiKey, isLogged: false);
  final MapCustomInfoWindowController _customInfoWindowController = MapCustomInfoWindowController();
  BlastPinLocation? _setLocation;

  @override
  void initState() {
    _setLocation = widget.initialBPLocation;
    super.initState();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    double infoViewWidth = defMaxInfoWindowWidth;
    if(widget.width-50 < infoViewWidth){
      infoViewWidth = widget.width-50;
    }
    markerInfoWidget = MapCustomInfoWindow(
      (double top, double left, double width, double height){},
      controller: _customInfoWindowController,
      height: defInfoWindowHeigth,
      width: infoViewWidth,
      offset: defInfoWindowOffset,
    );

    return super.build(context);
  }

  @override
  Future<void> onMapCreated(GoogleMapController controller) async{
    await super.onMapCreated(controller);

    _customInfoWindowController.googleMapController = controller;
    currentPolygons = MapManager().getMapPolygons(MapDisplayType.events);

    _markerBitmapLocation = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: MapUtils.getMarkerSize(ObjectSize.normal),
      ),
      'assets/images/location/DeviceLocationIcon.png',
    );
    _markerBitmapLocationFly = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: MapUtils.getMarkerSize(ObjectSize.normal),
      ),
      'assets/images/location/DeviceLocationIconFly.png',
    );

    addSingleMarkerToPosition(_markerBitmapLocation,currentCameraPosition.target);
    DateTimeUtils.waitWhile(
      () => googleMapLoaded,
      const Duration(milliseconds: 100),
    ).then((value) async {
      if(_setLocation != null && widget.onSetMapLocation != null){
        await widget.onSetMapLocation!(_setLocation);
      }
      _resolvePlaceOnMap(currentCameraPosition.target);
    });
  }

  @override
  Future<void> onCameraMoveStarted() async {
    if(googleMapLoaded){
      //debugPrint('Google maps camera movement started. Position: ${currentMarkers.first.position.toString()}');
      addSingleMarkerToPosition(_markerBitmapLocationFly, currentMarkers.first.position);
      if(currentMapGesture == MapGesture.move && _customInfoWindowController.hideInfoWindow != null){
        _customInfoWindowController.hideInfoWindow!();
      }
    }
  }

  @override
  Future<void> onCameraMove(CameraPosition position) async{
    if(googleMapLoaded){
      //debugPrint('Google maps camera movement update. Gesture: ${currentMapGesture.toString()},Position: ${position.target.toString()}');
      switch(currentMapGesture){
        case MapGesture.move:
          addSingleMarkerToPosition(_markerBitmapLocationFly, position.target);
          break;
        case MapGesture.scale:
        case MapGesture.tap:
          if(position.target != currentMarkers.first.position){
            // marker is scale center
            googleMapController.moveCamera(CameraUpdate.newLatLng(currentMarkers.first.position));
          }
          break;
      }
    }
    await super.onCameraMove(position);
  }

  @override
  Future<void> onCameraMoveFinished() async {
    if(googleMapLoaded){
      debugPrint('Google maps camera movement finished.');
      LatLng currentPosition = currentCameraPosition.target;
      addSingleMarkerToPosition(_markerBitmapLocation, currentPosition);
      if(currentMapGesture == MapGesture.move){
        await _resolvePlaceOnMap(currentPosition);
      }
      currentMapGesture = MapGesture.tap;
    }
  }

  Future<void> _resolvePlaceOnMap(LatLng position) async{
    try {  
      bool isValidLocation = MapManager().isValidLocation(position);
      if(isValidLocation){
        debugPrint('Valid location set on map.');
        BlastPinLocation? bpLocation = _setLocation ?? await _getPlaceFromLatLng(position);
        if(bpLocation != null){
          _showInfoWindow(
            bpLocation.shortLocationString,
            onTap: (){
              if(widget.onSetMapLocation != null){
                widget.onSetMapLocation!(bpLocation);
              }
            }
          );
          if(_setLocation == null && widget.onSetMapLocation != null){
            widget.onSetMapLocation!(bpLocation);
          }
        }
      } else {
        debugPrint('Not valid location set on map.');
        _showInfoWindow(
          LanguageManager().getText('This address is out of the area for now.')
        );
      }
    } catch (e) {
      debugPrint('Error on _resolvePlaceOnMap: ${e.toString()}');
    }
    _setLocation = null;
  }

  Future<BlastPinLocation?> _getPlaceFromLatLng(LatLng position) async {
    try {  
      GoogleGeocodingResponse reversedSearchResults = await _googleGeocodingApi.reverse(
        '${position.latitude},${position.longitude}',
        language: LanguageManager().getCurrentLanguage(),
        resultType: 'street_address'
      );
      if(reversedSearchResults.results.isNotEmpty){
        debugPrint('Selected location: ${reversedSearchResults.results.first.formattedAddress}');
        String? shortAddress = MapUtils.shortAddressFromGoogleAddressComponents(reversedSearchResults.results.first.addressComponents);
        if(shortAddress != null){
          BlastPinLocation bpLocation = BlastPinLocation(
            googleId: reversedSearchResults.results.first.placeId,
            locationLatLong: position,
            locationString: reversedSearchResults.results.first.formattedAddress,
            shortLocationString: shortAddress
          );
          return bpLocation;
        }
      }
    } catch (e) {
      debugPrint('Error on _getPlaceFromLatLng: ${e.toString()}');
    }
    return null;
  }

  void _showInfoWindow(String text, {Function? onTap}){
    Widget infoWindow = GestureDetector(
      onTap: () {
        if(onTap != null){
          onTap();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: defBackgroundPrimaryColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              width: double.infinity,
              height: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
                  textAlign: TextAlign.center,
                )
              ),
            ),
          ),
          Triangle.isosceles(
            edge: Edge.BOTTOM,
            child: Container(
              color: defBackgroundPrimaryColor,
              width: 20.0,
              height: 10.0,
            ),
          ),
        ],
      ),
    );

    if(_customInfoWindowController.addInfoWindow != null){
      _customInfoWindowController.addInfoWindow!(
        infoWindow,
        currentMarkers.first.position,
      );
    } else {
      debugPrint('Trying to set infoWindow without widget.');
    }
  }

  Future<void> setLocation(BlastPinLocation location) async{
    if(googleMapLoaded){
      _setLocation = location;
      currentMapGesture = MapGesture.move;
      await googleMapController.moveCamera(
        CameraUpdate.newLatLngZoom(
          location.locationLatLong,
          widget.initialZoomLevel ?? defDefaultMapZoom
        )
      );
    }
  }
}