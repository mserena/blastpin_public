import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget createTagList(
  {
    List<String> tags = const [],
    bool canDelete = false,
    bool showInfo = false,
    bool enabled = true, 
    Function? onTap,
  }
){
   return Wrap(
    runAlignment: WrapAlignment.start,
    alignment: WrapAlignment.start,
    crossAxisAlignment: WrapCrossAlignment.start,
    spacing: 10,
    runSpacing: 10,
    children: [
      for(int idxTag = 0; idxTag < tags.length; idxTag++) ...{
        createTagView(
          tag: tags[idxTag],
          canDelete: canDelete,
          enabled: enabled,
          onTap: onTap
        ),
      },
      if(canDelete && showInfo) ...{
        Container(
          padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
          child: Text(
            LanguageManager().getText('Add new tag'),
            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
          ),
        )
      }
    ],
  );
}

Widget createTagView(
  {
    required String tag,
    required bool canDelete,
    Color enabledBackgroundColor = defTagEnabledBackgroundColor,
    Color disabledBackgroundColor = defTagDisabledBackgroundColor,
    bool enabled = true,
    Function? onTap
  }
){
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: (){
          if(onTap != null){
            onTap(tag);
          }
        },
        child:  Container(
          padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
          decoration: BoxDecoration(
            color: enabled ? enabledBackgroundColor : disabledBackgroundColor,
            border: Border.all(
              color: enabled ? enabledBackgroundColor : disabledBackgroundColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(25))
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageManager().getText(tag),
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
              ),
              if(canDelete) ...{
                const SizedBox(width: 10),
                Icon(
                  FontAwesomeIcons.xmark,
                  color: defBodyContrastTextColor,
                  size: ImageUtils.getIconSize(ObjectSize.normal),
                )
              }
            ]
          ),
        )
      ),
    );
  }