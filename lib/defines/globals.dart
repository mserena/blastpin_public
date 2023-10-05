import 'package:blastpin/objects/blastpin_currency.dart';
import 'package:blastpin/prefabs/map/map_display_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Global Variables
final GlobalKey<NavigatorState> gNavigatorStateKey = GlobalKey<NavigatorState>();
final GlobalKey<MapDisplayViewState> gMapDisplayViewStateKey = GlobalKey<MapDisplayViewState>();
Uri? gInitialAppUri;

//Device
const double defMinExpandedViewWidth = 715;
const double defMinExpandedViewHeigth = 550;
enum DeviceView{
  compact,
  expanded
}
enum DeviceType{
  web,
  mobile
}

//Objects
enum ObjectSize{
  big,
  normal,
  small
}

enum TopBarPosition{
  left,
  center,
  right
}

//Google Maps
const String defGoogleMapsApiKey = 'secret';
enum MapGesture{
  tap,
  move,
  scale
}
enum MapDisplayType{
  empty,
  cities,
  events
}
const double defDefaultMapZoom = 12;
const double defOnMoveToPointMapZoom = 16;
const String defPolygonAllMapId = 'allMap';
const double defCitiesZoom = 10;
const Size defCitiesMarkerSize = Size(75,75);
const MarkerId defDeviceLocationMarkerId = MarkerId('deviceLocation');
const int defMinLengthAutocomplete = 3;
const Duration defDelayUserInput = Duration(milliseconds: 1500);

//Notifications
enum CustomNotificationType{
  // Connection
  connectionError,
  // Location
  locationDisabled,
  locationDeneided,
  locationDeneidedForever,
  // SignIn
  signinCheckEmailLink,
  signinDone,
  signinCanceled,
  signinError,
  //Content
  publishDone,
  publishError,
  //General error
  unknownError,
  //Not implemented notification
  unknown,
}
CustomNotificationType getCustomNotificationTypeFromString(String notificationTypeStr) {
  for (CustomNotificationType type in CustomNotificationType.values) {
    String currentTypeStr = type.toString().split('.').last;
    if (currentTypeStr == notificationTypeStr) {
        return type;
    }
  }
  return CustomNotificationType.unknown;
}

//SignIn
enum SignInOperationResult{
  done,
  error,
  canceled
}
const String defLocalStorageSigninEmail = 'defLocalStorageSigninEmail';

//Events
enum EventType{
  //session events
  eUserSignInEvent,
  eUserSignOutEvent,
  eUserEmailLinkSent,
}

//Content
enum ContentBlastPinStatus{
  creating,   //When user is on creation process
  uploading,  //When content is on upload process
  updating,   //When content is on update process
  review,     //When content is on review
  published,  //Content published
  rejected,   //Content can't be published
  deleted,    //Content is deleted
  error       //Error on upload process
}
enum EditContentStep{
  type,
  description,
  price,
  when,
  where,
  multimedia,
  tags,
  links,
  preview
}
enum TicketType{
  free,
  paid
}
enum ContentBlastPinType{
  event,
  place
}
enum SocialLinkType{
  whatsapp,
  telephone,
  email,
  website,
  instagram,
  tiktok,
  youtube
}
const String defLocalStorageEditContentCurrentStep = 'defLocalStorageEditContentCurrentStep'; 
const String defLocalStorageEditContentData = 'defLocalStorageEditContentData';
const String defLocalStorageEditContentMedia = 'defLocalStorageEditContentMedia';
const int defMaxTextLinesToShow = 4;
const int defMaxTitleLength = 30;
const int defMaxDescriptionLength = 500;
const int defMaxContentMediaFiles = 6;
const Duration defDelayStoreLanguages = Duration(milliseconds: 500);
const Duration defMaxAnticipation = Duration(days:730);
const String defContentLanguageTitleKey = 'Title';
const String defContentLanguageDescriptionKey = 'Description';

//Content Event
enum EventRepeat{
  unique,
  daily,
  weekly,
  monthly,
  annually
}

//User
enum UserActions{
  delete,
  omit
}

//Languages
const String defDefaultLanguage = 'en';
const List defDefaultLanguagesList = [
  {"isoCode": "es", "name": "Spanish", "flag": "es"},
  {"isoCode": "en", "name": "English", "flag": "gb"},
  {"isoCode": "ca", "name": "Catalan", "flag": "es-ct"},
];

//DateTime
const List<String> defWeekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
const List<String> defWeekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> defMonths = ['January','February','March','April','May','June','July','August','September','October','November','December'];
const List<String> defMonthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

//Currency
const String defDefaultCurrency = "EUR"; 
final List<BlastPinCurrency> defCurrencies = [
  BlastPinCurrency(code: 'EUR', name: 'Euro', symbol: '€')
];

//Firebase
const String defGeneralBucket = 'secret';
const String defUserImageProfileBucketPath = '/UserProfileImages/';
const String defContentBucketPath = '/Content/';