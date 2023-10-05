import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/prefabs/map/map_view.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/utils/map_uitls.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapStaticView extends MapView {

  const MapStaticView(
    {
      required key,
      required canInitializeMap,
      required double width,
      required double height,
      LatLng? initialLatLng,
      double? initialZoomLevel,
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
  MapStaticViewState createState() => MapStaticViewState();
}

class MapStaticViewState extends MapViewState<MapStaticView>{
  late final BitmapDescriptor _markerBitmapLocation;

  @override
  Widget build(BuildContext context){
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: super.build(context)
        ),
        PointerInterceptor(
          intercepting: true,
          //debug: true,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
          )
        )
      ]
    );
  }

  @override
  Future<void> onMapCreated(GoogleMapController controller) async{
    await super.onMapCreated(controller);
    
    currentPolygons = MapManager().getMapPolygons(MapDisplayType.events);

    _markerBitmapLocation = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: MapUtils.getMarkerSize(ObjectSize.normal),
      ),
      'assets/images/location/DeviceLocationIcon.png',
    );

    addSingleMarkerToPosition(_markerBitmapLocation,currentCameraPosition.target);
  }
}