import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/prefabs/alerts/social_alert_dialog.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/prefabs/map/map_static_view.dart';
import 'package:blastpin/prefabs/tags/tag_view.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/social_link_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as google_places_sdk;

class ContentView extends StatefulWidget {
  final double width;
  final Content content;

  const ContentView({super.key, required this.content, required this.width});

  @override
  State<ContentView> createState() => ContentViewState();
}

class ContentViewState<T extends ContentView> extends State<T> with AfterLayoutMixin<T> {
  bool isLoading = false;
  bool showAllAbout = false;

  //Map
  final GlobalKey<MapStaticViewState> _mapStaticStateKey = GlobalKey<MapStaticViewState>();
  late final google_places_sdk.FlutterGooglePlacesSdk _googlePlacesSdk;
  late Future _googlePlacesSdkInitialized;

  @override
  initState(){
    debugPrint('Build content of type ${widget.content.type.toString()}');
    _googlePlacesSdk = google_places_sdk.FlutterGooglePlacesSdk(
      defGoogleMapsApiKey,
      locale: Locale(LanguageManager().getCurrentLanguage())
    );
    _googlePlacesSdkInitialized = _googlePlacesSdk.isInitialized();
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    debugPrint('Content view after first layout.');
  }

  void setLoading(bool loading){
    setState(() {
      isLoading = loading;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildMedia(0),
              Positioned(
                bottom: 30,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: defPrimaryColor
                    ),
                    color: defPrimaryColor
                  ),
                  child: Icon(
                    ImageUtils.getContentTypeIcon(widget.content.type),
                    color: defBodyContrastTextColor,
                    size: ImageUtils.getIconSize(ObjectSize.normal,context: context),
                  ),
                )
              ),
            ],
          ),
          _buildMainInfo(),
          buildWhen(),
          _buildWhere(),
          _buildMedia(1),
          _buildAbout(),
          _buildMedia(2),
          _buildMedia(3),
          _buildMedia(4),
          _buildMedia(5),
          _buildSocial(),
          const SizedBox(height: defTopBarHeigth),
        ]
      ),
    );
  }

  Widget buildWhen(){
    return Container();
  }

  Widget _buildWhere(){
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.locationDot,
                size: ImageUtils.getIconSize(ObjectSize.normal),
                color: defPrimaryColor,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.content.location!.locationString,
                  style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
                )
              )
            ]
          ),
          const SizedBox(height: 15),
          MapStaticView(
            key: _mapStaticStateKey,
            canInitializeMap: _googlePlacesSdkInitialized,
            width: widget.width,
            height: widget.width/1.5,
            initialLatLng: widget.content.location!.locationLatLong,
            initialZoomLevel: 17,
          ),
          const SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _buildMainInfo(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,   
      children: [
        Text( 
          widget.content.getLanguageString(defContentLanguageTitleKey),
          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleLarge!
        ),
        const SizedBox(height: 15),
        Wrap(
          runAlignment: WrapAlignment.start,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            if(widget.content.location != null) ...{
              FutureBuilder<String?>(
                future: DeviceManager().getDistanceBetweenDeviceStr(widget.content.location!.locationLatLong),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                    return createTagView(
                      tag: snapshot.data!,
                      canDelete: false,
                      enabledBackgroundColor: defErrorTextColor
                    );
                  } else {
                    return Container();
                  }
                }
              ),
            },
            createTagView(
              tag: widget.content.ticket.getPriceString(),
              canDelete: false,
              enabledBackgroundColor: defPrimaryColor
            ),               
            createTagView(
              tag: widget.content.mainTag!,
              canDelete: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocial(){
    if(widget.content.socialLinks.isNotEmpty){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          createTitleAndSubtitle(
            'Contact',
            'Do you have questions? Contact the organizer.'
          ),
          Wrap(
            runAlignment: WrapAlignment.start,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var socialLinkType in widget.content.socialLinks.keys) ...{
                createIconButton(
                  icon: SocialLinkUtils.getIcon(socialLinkType),
                  iconSize: ImageUtils.getIconSize(ObjectSize.normal),
                  iconColor: defBodyContrastTextColor,
                  backgroundColor: defPrimaryColor,
                  width: ImageUtils.getSquareButtonSize(ObjectSize.normal),
                  height: ImageUtils.getSquareButtonSize(ObjectSize.normal),
                  onPress: (){
                    openSocialLink(socialLinkType, widget.content);
                  }
                ),
              },
            ],
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildMedia(int idx){
    if(widget.content.media.isNotEmpty && idx < widget.content.media.length){
      XFile file = widget.content.media[idx];
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: SizedBox(
              width: widget.width,
              height: widget.width,
              child: Image.network(
                file.path,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
        ]
      );
    } else {
      return Container();
    }
  }

  Widget _buildAbout(){
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          createTitleAndSubtitle(
            'About',
            widget.content.getLanguageString(defContentLanguageDescriptionKey),
            translateSubtitle: false,
            showAllLines: showAllAbout,
            onChangeShowAllLines: () {
              setState(() {
                showAllAbout = !showAllAbout;
              });
            }
          ),
          if(widget.content.extraTags.isNotEmpty) ...{
            const SizedBox(height: 15),
            createTagList(
              tags: widget.content.extraTags,
            )
          },
          const SizedBox(height: 20),
        ]
      )
    );
  }
}