import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/pages/editcontent/edit_content_preview_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_price_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_social_link_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_tags_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_description_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_multimedia_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_type_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_when_page.dart';
import 'package:blastpin/pages/editcontent/edit_content_where_page.dart';
import 'package:blastpin/pages/home_page.dart';
import 'package:blastpin/pages/loader_page.dart';
import 'package:blastpin/pages/my_content.dart';
import 'package:blastpin/pages/signin/signin_email_page.dart';
import 'package:blastpin/pages/signin/signin_page.dart';
import 'package:blastpin/pages/signin/signin_username_page.dart';
import 'package:blastpin/pages/signin/signout_page.dart';
import 'package:blastpin/pages/test_page.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:blastpin/services/services_loader.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class RouteManager{
  String? _currentRoute;
  Widget? _currentChild;

  // Singleton
  static final RouteManager _instance = RouteManager._internal();

  factory RouteManager(){
    return _instance;
  }

  RouteManager._internal();

  Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('new route, from $_currentRoute to ${settings.name}');
    _currentRoute = settings.name; 

    // Load services if not loaded
    if(!ServicesLoader().isServicesLoaded()){
      debugPrint('Services not loaded, go to loader...');
      _currentRoute = loaderRoute;
      return PageTransition(
        type: PageTransitionType.fade,
        child: LoaderPage(route: settings.name!),
      );      
    }

    switch (_currentRoute) {
      case testRoute:
        _currentChild = const TestPage();
        return _doFadePageTransition();
      case homeRoute:
        EventType? event = settings.arguments != null ? settings.arguments as EventType : null;
        _currentChild = HomePage(initialEvent: event);
        return _doFadePageTransition();
      case editContentTypeRoute:
        _currentChild = const EditContentTypePage();
        return _doFadePageTransition();
      case editContentDescriptionRoute:
        _currentChild = const EditContentDescriptionPage();
        return _doFadePageTransition();
      case editContentWhenRoute:
        _currentChild = const EditContentWhenPage();
        return _doFadePageTransition();
      case editContentWhereRoute:
        _currentChild = const EditContentWherePage();
        return _doFadePageTransition();
      case editContentTagsRoute:
        _currentChild = const EditContentTagsPage();
        return _doFadePageTransition();
      case editContentMultimediaRoute:
        _currentChild = const EditContentMultimediaPage();
        return _doFadePageTransition();
      case editContentSocialLinkRoute:
        _currentChild = const EditContentSocialLinkPage();
        return _doFadePageTransition();
      case editContentPriceRoute:
        _currentChild = const EditContentPricePage();
        return _doFadePageTransition();
      case editContentPreviewRoute:
        _currentChild = const EditContentPreviewPage();
        return _doFadePageTransition();
      case myContentRoute:
        _currentChild = const MyContentPage();
        return _doFadePageTransition();
      case signinRoute:
        _currentChild = const SignInPage();
        return _doFadePageTransition();
      case signinEmailRoute:
        _currentChild = const SignInEmailPage();
        return _doFadePageTransition();
      case signinUsernameRoute:
        _currentChild = const SignInUsernamePage();
        return _doFadePageTransition();
      case signoutRoute:
        return SignOutPage(gNavigatorStateKey.currentContext!);
      default:{
        _currentChild = const HomePage();
        return _doFadePageTransition();
      }
    }
  }

  Route<dynamic> _doFadePageTransition(){
    return PageTransition(
      type: PageTransitionType.fade,
      child: _currentChild!,
    );
  }

  // ignore: unused_element
  Route<dynamic> _doRightToLeftPageTransition(Widget oldChild){
    return PageTransition(
      type: PageTransitionType.rightToLeftJoined,
      childCurrent: oldChild, 
      child: _currentChild!,
    );
  }

  void popUntilHome({BuildContext? context, NavigatorState? safeNavigator}){
    if(safeNavigator != null){
      safeNavigator.popUntil(_routeToHome);
      _checkFinalRouteToHome(safeNavigator.context);
    } else if(context != null){
      Navigator.popUntil(context,_routeToHome);
      _checkFinalRouteToHome(context);
    }
  }

  bool _routeToHome(Route<dynamic> route){
    if(route.settings.name == homeRoute){
      return true;
    }
    return false;
  }

  void _checkFinalRouteToHome(BuildContext context){
    if(ModalRoute.of(context) != null){
      if(ModalRoute.of(context)!.settings.name == null){
        Navigator.pushNamed(context,homeRoute);
      }
    } else {
      Navigator.pushNamed(context,homeRoute);
    }
  }

  String getCurrentRoute(){
    return _currentRoute ?? unknownRoute;
  }
}