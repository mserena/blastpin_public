import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:blastpin/services/routes/route_manager.dart';
import 'package:blastpin/utils/content_utils.dart';
import 'package:flutter/material.dart';

mixin EditContent<T extends StatefulWidget> on State<T>, AfterLayoutMixin<T> {
  late EditContentStep step;
  bool isLoading = false;

  @override
  void afterFirstLayout(BuildContext context) {
    if(EditContentManager().getEditContent() == null && RouteManager().getCurrentRoute() != editContentTypeRoute){
      debugPrint('Error: Trying to access add content view ${T.toString()} wihout EditContent object.');
      EditContentManager().setCurrentStep(EditContentStep.type, force: true);
      Navigator.pushNamedAndRemoveUntil(context, editContentTypeRoute, (route) => false);
    } else {
      EditContentManager().setCurrentStep(step);
    }
  }

  void setLoading(bool loading){
    setState(() {
      isLoading = loading;
    });
  }

  void refreshView(){
    setState(() {
    });
  }

  void nextStep(){
    if(step != EditContentStep.preview){
      setState(() {
        isLoading = false;
        Navigator.pushNamedAndRemoveUntil(
          context,
          ContentUtils.getEditContentStepRoute(ContentUtils.getNextStep(step)),
          (route) => false
        );
      });
    }
  }
}