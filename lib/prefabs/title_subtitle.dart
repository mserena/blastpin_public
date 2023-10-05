import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Widget createTitleAndSubtitle(
  String title,
  String subtitle,
  {
    bool translateSubtitle = true,
    bool showAllLines = true,
    Function? onChangeShowAllLines
  }
){
  if(translateSubtitle){
    subtitle = LanguageManager().getText(subtitle);
  }
  return Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          LanguageManager().getText(title),
          textAlign: TextAlign.left,
          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleLarge!
        ),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: _showText(subtitle, showAllLines, onChangeShowAllLines)
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget _showText(String? text, bool showAllText, Function? onChangeShowAllLines){
  if(text != null && text != ''){
    String showMore = '...${LanguageManager().getText('show more')}';
    if(!showAllText){
      return LayoutBuilder(builder: (context, size) {
        final span = TextSpan(
          text: text,
          style : Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
        );
        final textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr
        );
        List<String> lines = TextUtils.getStringLines(text,textPainter,size.maxWidth-20);
        if(lines.length > defMaxTextLinesToShow){
          return RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              children: [
                for(int idxLine = 0; idxLine < defMaxTextLinesToShow-1; idxLine++) ...{
                  TextSpan(
                    text: '${lines[idxLine]} ',
                    style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
                  ),
                },
                TextSpan(
                  text: lines[defMaxTextLinesToShow-1].substring(0,lines[defMaxTextLinesToShow-1].length-showMore.length),
                  style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
                ),
                TextSpan(
                  text: showMore,
                  style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
                  mouseCursor: SystemMouseCursors.click,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () { 
                      if(onChangeShowAllLines != null){
                        onChangeShowAllLines();
                      }
                    },
                ),
              ],
            ),
          );
        } else {
          return Text(
            text,
            textAlign: TextAlign.left,
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
          );
        }
      });
    }
    return Text(
      text,
      textAlign: TextAlign.left,
      style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
    );
  } else {
    return Container();
  }
}