import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ButtonAuth{
  all,
  loggedIn,
  loggedOut
}

class ButtonRoute  {
  ButtonRoute({required this.route, required this.name, required this.icon, required this.auth, required this.devices});

  final String route;
  final String name;
  final IconData icon;
  final ButtonAuth auth;
  final List<DeviceType> devices;
}

List<ButtonRoute> buttonRoutes = [
  ButtonRoute(
    route: signinRoute,
    name: LanguageManager().getText('Sign In'),
    icon: FontAwesomeIcons.user,
    auth: ButtonAuth.loggedOut,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
  ButtonRoute(
    route: homeRoute,
    name: LanguageManager().getText('My account'),
    icon: FontAwesomeIcons.user,
    auth: ButtonAuth.loggedIn,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
  ButtonRoute(
    route: homeRoute,
    name: LanguageManager().getText('Favorites'),
    icon: FontAwesomeIcons.heart,
    auth: ButtonAuth.all,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
  ButtonRoute(
    route: editContentTypeRoute,
    name: LanguageManager().getText('My events and places'),
    icon: FontAwesomeIcons.map,
    auth: ButtonAuth.loggedIn,
    devices: [DeviceType.web,DeviceType.mobile],
  ),  
  ButtonRoute(
    route: editContentTypeRoute,
    name: LanguageManager().getText('Add event or place'),
    icon: FontAwesomeIcons.plus,
    auth: ButtonAuth.all,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
  ButtonRoute(
    route: homeRoute,
    name: LanguageManager().getText('Settings'),
    icon: FontAwesomeIcons.gear,
    auth: ButtonAuth.all,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
  ButtonRoute(
    route: homeRoute,
    name: LanguageManager().getText('Questions'),
    icon: FontAwesomeIcons.question,
    auth: ButtonAuth.all,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
  ButtonRoute(
    route: signoutRoute,
    name: LanguageManager().getText('Sign out'),
    icon: FontAwesomeIcons.doorOpen,
    auth: ButtonAuth.loggedIn,
    devices: [DeviceType.web,DeviceType.mobile],
  ),
];