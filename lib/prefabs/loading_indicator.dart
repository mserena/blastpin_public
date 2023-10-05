import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget createCenterLogoLoader(BuildContext context){
  return Center( 
    child: SizedBox(
      width: DeviceManager().getDeviceView(context) == DeviceView.expanded ? MediaQuery.of(context).size.width/4 : MediaQuery.of(context).size.width/2,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SpinKitRipple(
              size: 300,
              color: defPrimaryColor.withAlpha(100),
              duration: const Duration(seconds: 3),
            ),
            Image.asset(
              'assets/images/logo/BlastPinLogo.png',
              width: 200,
              height: 58,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget createLoadingIndicator({String? text, double? size})
{
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SpinKitRing(
          color: defPrimaryColor,
          lineWidth: 3,
          size: size ?? ImageUtils.getAnimationSize(ObjectSize.big),
        ),
        if(text != null) ...{
          const SizedBox(height: 15),
          Text(
            '${LanguageManager().getText(text)}...',
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!
          ),
        }
      ],
    ),
  );
}

Container createContainerLoading(double width, double height, {String? text}){
  return Container(
    width: width,
    height: height,
    color: const Color.fromARGB(175, 0, 0, 0),
    child: Center(
      child: createLoadingIndicator(text: text),
    )
  );
}

AbsorbPointer createBlockerLoading(BuildContext context, {String? text}){
  AbsorbPointer loader = AbsorbPointer(
    absorbing: true,
    child: createContainerLoading(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
      text: text,
    ),
  );
  return loader;
}