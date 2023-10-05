import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/services/authentification_manager.dart';
import 'package:flutter/material.dart';

class SignOutPage extends ModalRoute<void> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.2);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  late BuildContext _currentContext;

  SignOutPage(this._currentContext){
    AuthentificationManager().signOut().then((value) {
      Navigator.pop(_currentContext);
    });
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    _currentContext = context;
    return Material(
      type: MaterialType.transparency,
      child: createBlockerLoading(context),
    );
  }
}