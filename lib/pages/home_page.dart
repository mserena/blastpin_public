import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/prefabs/map/map_display_view.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element_image.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element_title.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_menu_drawer.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/services/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as google_places_sdk;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  final EventType? initialEvent;

  const HomePage({super.key, this.initialEvent});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin, AfterLayoutMixin<HomePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _searchingLocation = false;
  
  late final google_places_sdk.FlutterGooglePlacesSdk _googlePlacesSdk;
  late Future _googlePlacesSdkInitialized;

  @override
  void initState() {
    _googlePlacesSdk = google_places_sdk.FlutterGooglePlacesSdk(
      defGoogleMapsApiKey,
      locale: Locale(LanguageManager().getCurrentLanguage())
    );
    _googlePlacesSdkInitialized = _googlePlacesSdk.isInitialized();

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if(widget.initialEvent != null){
      _processEvents(widget.initialEvent!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _createHomeView(),
      ),
      endDrawer: createTopBarMenuDrawer(context, _onReturn),
      onEndDrawerChanged: (isOpened) {
        MapManager().setMapPaused(isOpened);
      },
    );
  }

  Widget _createHomeView()
  {
    return Stack(
      children: [
        MapDisplayView(
          key: gMapDisplayViewStateKey,
          canInitializeMap: _googlePlacesSdkInitialized,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        _createActionButtons(),
        _createTopBar(),
      ],
    );
  }

  Widget _createTopBar(){
    return TopBar(
      elements: [
        TopBarElement(
          element: createTopBarElementImage(
            path: 'assets/images/logo/BlastPinLogoSmall.png',
            width: DeviceManager().getDeviceView(context) == DeviceView.expanded ? 30 : 20,
            height: DeviceManager().getDeviceView(context) == DeviceView.expanded ? 64 : 34
          ),
          position: TopBarPosition.left
        ),
        TopBarElement(
          element: createTopBarElementTitle(
            title: 'BlastPin',
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineLarge!
          ),
          position: TopBarPosition.left
        ),        
        TopBarElement(
          element: createTopBarElementTitle(
            title: ' ${MapManager().getMapCurrentArea().id}',
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.displayLarge!
          ),
          position: TopBarPosition.left
        ),
        TopBarElement(
          element: createIconButton(
            icon: FontAwesomeIcons.bars,
            onPress: () {
              _scaffoldKey.currentState!.openEndDrawer();
            }
          ),
          position: TopBarPosition.right
        ),
      ],
    );
  }

  Widget _createActionButtons(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            createIconButton(
              icon: FontAwesomeIcons.locationCrosshairs,
              animation: _searchingLocation,
              onPress: _onPressLocation,
            ),
            createIconButton (
              icon: FontAwesomeIcons.shuffle,
              onPress: _onPressShuffle,
            ),
            createIconButton (
              icon: FontAwesomeIcons.sliders,
              onPress: _onPressFilters,
            ),
          ]
        )
      ) 
    );
  }

  void _onPressLocation() async{
    if(!_searchingLocation){
      setState(() {
        _searchingLocation = true;
      });
      LatLng? deviceLocation = await DeviceManager().getDeviceLocation();
      if(deviceLocation != null){
        await MapManager().setMapDeviceLocation(deviceLocation);
      }
      setState(() {
        _searchingLocation = false;
      });
    }
  }

  void _onPressShuffle() async{

  }

  void _onPressFilters() async{

  }

  void _onReturn(dynamic result){
    if(result != null){
      EventType eventType = result as EventType;
      _processEvents(eventType);
    }
    setState(() {});
  }

  void _processEvents(EventType type){
    if(type == EventType.eUserSignInEvent){
      NotificationManager().addNotification(CustomNotificationType.signinDone);
    } else if(type == EventType.eUserEmailLinkSent){
      NotificationManager().addNotification(CustomNotificationType.signinCheckEmailLink);
    }
  }
}