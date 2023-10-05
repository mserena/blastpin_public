import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/main_menu.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/package_info_manager.dart';
import 'package:blastpin/services/user_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';

Widget createTopBarMenuDrawer(BuildContext context, Function onReturn) {
  List<ButtonRoute> currentButtonRoutes = <ButtonRoute>[];
  for(int idxButton = 0; idxButton < buttonRoutes.length; idxButton++){
    ButtonRoute currentButtonRoute = buttonRoutes[idxButton];
    if(currentButtonRoute.auth != ButtonAuth.all){
      if(UserManager().isSignedIn() && currentButtonRoute.auth != ButtonAuth.loggedIn ||
        !UserManager().isSignedIn() && currentButtonRoute.auth != ButtonAuth.loggedOut){
          continue;
      }
    }
    if(!currentButtonRoute.devices.contains(DeviceManager().getDeviceType())){
      continue;
    }
    currentButtonRoutes.add(currentButtonRoute);
  }
  double width = DeviceManager().getDeviceView(context) == DeviceView.expanded ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.75;
  return Theme( 
    data: Theme.of(context).copyWith(
      canvasColor: Colors.transparent,
    ),
    child:Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: width,
        height: MediaQuery.of(context).size.height,
        child: Drawer(
          child: Container(
            color: defBackgroundPrimaryColor,
            child: ListView(
              children: [
                Container(
                  height: defTopBarHeigth * 2,
                  color: defPrimaryColor,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 15,
                          width: width,
                          decoration: const BoxDecoration(
                            color: defBackgroundPrimaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(UserManager().isSignedIn()) ...{
                              Text(
                                LanguageManager().getText('Hello, ${UserManager().getUsername()}!'),
                                textAlign: TextAlign.start,
                                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleLarge!,
                              ),
                            } else ...{
                              Text(
                                LanguageManager().getText('Hello!'),
                                textAlign: TextAlign.start,
                                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleLarge!,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                LanguageManager().getText('Sign up for a experience based on your interests, buy tickets, connect with people and more.'),
                                textAlign: TextAlign.start,
                                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleSmall!,
                              ),
                            }
                          ],
                        )
                      )
                    ],
                  ),
                ), 
                const SizedBox(height: 20),
              ] +
              currentButtonRoutes.map((button) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                  child: ListTile(
                    leading: Icon(
                      button.icon,
                      size: ImageUtils.getIconSize(ObjectSize.normal,context: context),
                    ),
                    iconColor: defBodyContrastTextColor,
                    title: Text(
                      button.name,
                      style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!, 
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: ImageUtils.getIconSize(ObjectSize.small,context: context),
                      color: defBodyTextColor,
                    ),
                    onTap: () async {
                      //hide drawer
                      Navigator.of(context).pop();
                      dynamic result = await Navigator.pushNamed(
                        context,
                        button.route
                      );
                      onReturn(result);
                    },
                  ),
                );
              }).toList()
              +
              [
                Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/images/logo/BlastPinLogoBlackWhite.png',
                        width: 133,
                        height: 38,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${LanguageManager().getText('Version')} ${PackageInfoManager().getVersion()}',
                        textAlign: TextAlign.center,
                        style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodySmall!,
                      ),
                      Text(
                        LanguageManager().getText('Created with pasion.'),
                        textAlign: TextAlign.center,
                        style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodySmall!,
                      ),
                    ],
                  )
                )
              ]
            )
          ),
        )
      ),
    )
  );
}