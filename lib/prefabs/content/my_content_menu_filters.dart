import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyContentMenuFilters extends ModalRoute<void> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.2);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  double viewWidth;

  MyContentMenuFilters(
    {
      required this.viewWidth
    }
  );

  @override
  void dispose() {
    debugPrint('Dispose myContentMenuFilters');
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Material(
      type: MaterialType.transparency,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: viewWidth,
              height: MediaQuery.of(context).size.height/2,
              decoration: const BoxDecoration(
                color: defBackgroundTertiaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: createIconButton(
                      icon: FontAwesomeIcons.xmark,
                      iconColor: defPrimaryColor,
                      iconSize: ImageUtils.getIconSize(ObjectSize.small),
                      onPress:(){
                        Navigator.pop(context);
                      }
                    ),
                  )
                ],
              )
            )
          );
        }
      )
    );
  }

  @override
  Widget buildTransitions( BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
