import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Flag extends StatelessWidget {
  final String isoCode;
  final String flagName;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget replacement;
  final double? borderRadius;
  final Function? onPress;
  final bool selected;

  const Flag.fromString(
    this.isoCode,
    this.flagName, 
    {
      Key? key,
      this.height,
      this.width,
      this.fit = BoxFit.contain,
      this.replacement = const SizedBox.shrink(),
      this.borderRadius = 0,
      this.onPress,
      this.selected = false,
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String countryName = flagName.toLowerCase();
    String assetName = 'assets/images/flags/$countryName.svg';

    var returnWidget = MouseRegion(
      cursor: onPress != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          if(onPress != null){
            onPress!(isoCode);
          }
        },
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius!),
            child: Stack(
              children: [
                SvgPicture.asset(
                  assetName,
                  semanticsLabel: isoCode,
                  fit: fit,
                ),
                if(!selected) ...{
                  Container(
                    color: Colors.black.withAlpha(150)
                  )
                }
              ],
            ),
          )
        ),
      ),
    );
    return returnWidget;
  }
}