import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/map/blastpin_location.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/input_box/input_data_box_with_suggestions_widget.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/map/map_picker_view.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/utils/list_utils.dart';
import 'package:blastpin/utils/map_uitls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as flutter_google_maps;

class EditContentWherePage extends StatefulWidget {
  const EditContentWherePage({super.key});

  @override
  State<EditContentWherePage> createState() => EditContentWherePageState();
}

class EditContentWherePageState extends State<EditContentWherePage> with AfterLayoutMixin<EditContentWherePage>, EditContent<EditContentWherePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  //Autocomplete
  final FocusNode _whereTextFocusNode = FocusNode();
  final GlobalKey<InputDataBoxWithSuggestionsWidgetState> _inputLocationStateKey = GlobalKey<InputDataBoxWithSuggestionsWidgetState>();
  final GlobalKey<FormFieldState> _whereAutocompleteTextFormFieldKey = GlobalKey<FormFieldState>();
  final TextEditingController _whereAutocompleteTextController = TextEditingController();
  late final FlutterGooglePlacesSdk _googlePlacesSdk;
  late Future _googlePlacesSdkInitialized;
  Map<String,String>? _googleSuggestions;
  StreamSubscription<FindAutocompletePredictionsResponse>? _getGooglePlaceSuggestions;
  final List<PlaceField> _placeFields = [PlaceField.Id, PlaceField.Name, PlaceField.Address, PlaceField.AddressComponents, PlaceField.Location];
  Timer? _getGoogleSuggestionsDelay;

  //Map
  final GlobalKey<MapPickerViewState> _mapPickerStateKey = GlobalKey<MapPickerViewState>();

  //UI
  String _uiWhereText = '';
  double _viewWidth = defMaxEditContentViewWidth;

  EditContentWherePageState(){
    step = EditContentStep.where;
  }

  @override
  void initState() {
    if(EditContentManager().getEditContent() != null){
      if(EditContentManager().getEditContent()!.type == ContentBlastPinType.event){
        _uiWhereText = 'Tell us the exact place where the event will be held.';
      } else if(EditContentManager().getEditContent()!.type == ContentBlastPinType.place){
        _uiWhereText = 'Tell us where the place is.';
      }
    }

    _googlePlacesSdk = FlutterGooglePlacesSdk(
      defGoogleMapsApiKey,
      locale: Locale(LanguageManager().getCurrentLanguage())
    );
    _googlePlacesSdkInitialized = _googlePlacesSdk.isInitialized();

    _whereTextFocusNode.addListener(() async {
      if (!_whereTextFocusNode.hasFocus) {
        if(_getGoogleSuggestionsDelay != null){
          _getGoogleSuggestionsDelay!.cancel();
        }
        await _cancelGoogleSuggestions(cleanSuggestions: false);
        if(_googleSuggestions != null && _googleSuggestions!.isEmpty){
          _googleSuggestions = null;
          _updateSuggestions();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            _createEditContentView(),
            createTopBarEditContent(context, setLoading, step),
            createBottomBarEditContent(context,_canContinue(),_onPressContinue),
            if(isLoading) ...{
              createBlockerLoading(context),
            }
          ],
        )
      )
    );
  }

  bool _canContinue(){
    bool canContinue = EditContentManager().getEditContent()!.location != null;
    return canContinue;
  }

  void _onPressContinue() async{
    nextStep();
  }

  Widget _createEditContentView(){
    _viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    _viewWidth = _viewWidth - 20;
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(0, defTopBarHeigth, 0, 0),
        width: _viewWidth,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            scrollbars: true,
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  createTitleAndSubtitle('Where',_uiWhereText),
                  _createWhereSelector(),
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          )
        ),
      )
    );
  }

  Widget _createWhereSelector(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDataBoxWithSuggestionsWidget(
          key: _inputLocationStateKey,
          formKey: _whereAutocompleteTextFormFieldKey,
          textController: _whereAutocompleteTextController,
          focusNode: _whereTextFocusNode,
          width: _viewWidth,
          hintText: 'Address or place',
          textStyle: EditContentManager().getEditContent()!.location == null ? Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium! : Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
          keyboardType: TextInputType.text,
          icon: FontAwesomeIcons.locationCrosshairs,
          iconColor: EditContentManager().getEditContent()!.location == null ? defDisabledTextColor : defPrimaryColor,
          onTextChanged: _getGoogleSuggestionsDelayed,
          onPressSuggestion: _onPressSuggestion,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            LanguageManager().getText('Can\'t find the address? Use the map.'),
            textAlign: TextAlign.left,
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
          ),
        ),
        const SizedBox(height: 20),
        MapPickerView(
          key: _mapPickerStateKey,
          canInitializeMap: _googlePlacesSdkInitialized,
          width: _viewWidth,
          height: _viewWidth/1.5,
          initialLatLng: EditContentManager().getEditContent()!.location != null ? EditContentManager().getEditContent()!.location!.locationLatLong : null,
          initialZoomLevel: 17,
          onSetMapLocation: _setLocation,
          initialBPLocation: EditContentManager().getEditContent()!.location,
        ),
      ],
    );
  }

  Future<void> _cancelGoogleSuggestions({bool cleanSuggestions = true}) async{
    if(_getGooglePlaceSuggestions != null)
    {
      if(cleanSuggestions && _googleSuggestions != null){
        _googleSuggestions!.clear();
      }
      await _getGooglePlaceSuggestions!.cancel();
      debugPrint('Google suggestion canceled.');
    }
  }

  void _getGoogleSuggestionsDelayed(String text){
    if(_getGoogleSuggestionsDelay != null){
      _getGoogleSuggestionsDelay!.cancel();
    }
    _getGoogleSuggestionsDelay = Timer.periodic(defDelayUserInput, (Timer t) => _getGoogleSuggestions());

    setState(() {
      EditContentManager().setLocation(null); 
    });
  }

  void _getGoogleSuggestions() async{
    try {
      if(_getGoogleSuggestionsDelay != null){
        _getGoogleSuggestionsDelay!.cancel();
      }

      String text = _whereAutocompleteTextController.text;
      if(text.length < defMinLengthAutocomplete)
      {
        if(_googleSuggestions == null || _googleSuggestions!.isNotEmpty){
          _googleSuggestions = <String, String>{};
          _updateSuggestions();
        }
        return;
      }
      await _cancelGoogleSuggestions();

      LatLng origin = LatLng(lat: MapManager().getMapCurrentArea().center.latitude, lng: MapManager().getMapCurrentArea().center.longitude);
      LatLng southwest = LatLng(lat: MapManager().getMapCurrentArea().bounds.southwest.latitude, lng: MapManager().getMapCurrentArea().bounds.southwest.longitude);
      LatLng northeast = LatLng(lat: MapManager().getMapCurrentArea().bounds.northeast.latitude, lng: MapManager().getMapCurrentArea().bounds.northeast.longitude);
      LatLngBounds locationBias = LatLngBounds(southwest: southwest, northeast: northeast);
      _getGooglePlaceSuggestions = _googlePlacesSdk.findAutocompletePredictions(
        text,
        countries: ['es'],
        placeTypeFilter: PlaceTypeFilter.ALL,
        origin: origin,
        locationBias: locationBias
      ).asStream().listen((FindAutocompletePredictionsResponse response) {
        var suggestions = response.predictions;
        _googleSuggestions = <String, String>{};
        // Filter suggestions
        List<String> availableAreas = ListUtils.listToLowerCase(MapManager().getAvailableAreas());
        for (var idxSuggestion = 0; idxSuggestion < suggestions.length; idxSuggestion++) {
          String suggestionCityCountryStr = suggestions[idxSuggestion].secondaryText.toLowerCase();
          List<String> suggestionCityCountryStrList = ListUtils.listToLowerCase(suggestionCityCountryStr.split(', '));
          bool suggestionOnAvailableAreas = ListUtils.getElementsAppearInBothList(availableAreas,suggestionCityCountryStrList).isNotEmpty;
          if(suggestionOnAvailableAreas){
            debugPrint('Found valid suggestion place: ${suggestions[idxSuggestion].fullText}');
            _googleSuggestions!.putIfAbsent(suggestions[idxSuggestion].placeId,() => suggestions[idxSuggestion].fullText);
          } else {
            debugPrint('Discarted suggestion place: ${suggestions[idxSuggestion].fullText}');
          }
        }
        _updateSuggestions();
      });    

      _getGooglePlaceSuggestions!.onDone(() => _getGooglePlaceSuggestions = null);
    } catch (e) {
      debugPrint('Error on fetch google place: ${e.toString()}');
    }
  }

  void _updateSuggestions(){
    if(_inputLocationStateKey.currentState != null){
      _inputLocationStateKey.currentState!.updateSuggestions(_googleSuggestions);
    }
  }

  Future<void> _onPressSuggestion(String googlePlaceId, String address) async{
    try{
      setLoading(true);
      debugPrint('Press on suggestion with googlePlaceId: $googlePlaceId');
      await _cancelGoogleSuggestions();
      FetchPlaceResponse googlePlace = await _googlePlacesSdk.fetchPlace(googlePlaceId, fields: _placeFields);
      if(googlePlace.place != null && googlePlace.place!.latLng != null){
        BlastPinLocation location = BlastPinLocation(
          googleId: googlePlaceId,
          locationLatLong: flutter_google_maps.LatLng(googlePlace.place!.latLng!.lat,googlePlace.place!.latLng!.lng),
          locationString: address,
          shortLocationString: MapUtils.shortAddressFromLongAddress(address)
        );
        if(_mapPickerStateKey.currentState != null){
          await _mapPickerStateKey.currentState!.setLocation(location);
        }
        _setLocation(location);
      }
    }catch(e){
      debugPrint('Error _onPressSuggestion ${e.toString()}');
    }
    setLoading(false);
  }

  void _setLocation(BlastPinLocation location) async{
    await EditContentManager().setLocation(location); 
    _whereAutocompleteTextController.text = EditContentManager().getEditContent()!.location!.shortLocationString;
    _googleSuggestions = null;
    _updateSuggestions();
    setState(() {});
  }
}