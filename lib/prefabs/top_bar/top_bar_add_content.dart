import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/alerts/alert_dialog.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/routes/route_manager.dart';
import 'package:blastpin/utils/content_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget createTopBarEditContent(BuildContext context, Function setLoading, EditContentStep currentStep){
  double spaceBetweenIndicators = 8;
  double stepInicatorWidth = ((MediaQuery.of(context).size.width/2)/EditContentStep.values.length) - spaceBetweenIndicators;
  if(stepInicatorWidth > defStepIndicatorMaxWidth){
    stepInicatorWidth = defStepIndicatorMaxWidth;
  }
  if(stepInicatorWidth > defTopBarHeigth){
    stepInicatorWidth = defTopBarHeigth;
  }
  return TopBar(
    elements: [
      TopBarElement(
        element: createIconButton(
          icon: FontAwesomeIcons.arrowLeft,
          onPress: () async {
            if(currentStep.index == 0 && EditContentManager().getEditContent() != null && EditContentManager().getEditContent()!.haveData()){
              await _storeAndExit(context, setLoading);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                ContentUtils.getEditContentStepRoute(ContentUtils.getPreviousStep(currentStep)),
                (route) => false
              );
            }
          }
        ),
        position: TopBarPosition.left
      ),
      TopBarElement(
        element: Row(
          children: [
            for (var stepType in EditContentStep.values) ...{
              createIconButton(
                icon: ContentUtils.getEditContentStepIcon(stepType),
                width: stepInicatorWidth,
                height: stepInicatorWidth,
                iconColor: stepType.index <= EditContentManager().getCurrentStep().index ? defPrimaryColor : defBodyTextColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                backgroundColor: currentStep == stepType ? defBackgroundPrimaryColor : Colors.transparent,
                onPress: stepType.index <= EditContentManager().getCurrentStep().index ? 
                  (){
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      ContentUtils.getEditContentStepRoute(stepType),
                      (route) => false
                    );
                  } 
                  : 
                  null,
              ),
              SizedBox(width: spaceBetweenIndicators),
            }
          ],
        ),
        position: TopBarPosition.center
      ),
      TopBarElement(
        element: createIconButton(
          icon: FontAwesomeIcons.xmark,
          onPress: () async{
            await _storeAndExit(context, setLoading);
          }
        ),
        position: TopBarPosition.right
      ),
    ],
  );
}

Future<void> _storeAndExit(BuildContext context, Function setLoading) async{
  final safeNavigator = Navigator.of(context);
  if(EditContentManager().getEditContent() != null){
    bool? response = await createAlertDialogYesNot(
      context,
      title: LanguageManager().getText('Save a draft for later?'),
      desc: LanguageManager().getText('Save a draft of your event or place and pick up where you left off later.'),
      closeButton: true,
      tapDismiss: true
    ).show();
    
    if(response != null){
      if(response){
        setLoading(true);
        await EditContentManager().storeCompleteEditContentLocal();
        setLoading(false);
      }else{
        await EditContentManager().cleanEditContent();
      }
      RouteManager().popUntilHome(safeNavigator: safeNavigator);
    }
  } else {
    RouteManager().popUntilHome(safeNavigator: safeNavigator);
  }
}