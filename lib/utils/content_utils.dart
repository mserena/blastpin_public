import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContentUtils{
  static Map<TicketType,String> getTicketTitles(){
    Map<TicketType,String> ticketTypeTitles = <TicketType,String>{};
    ticketTypeTitles.putIfAbsent(TicketType.free, () => 'Free access');
    ticketTypeTitles.putIfAbsent(TicketType.paid, () => 'Paid access');
    return ticketTypeTitles;
  }

  static IconData getEditContentStepIcon(EditContentStep step){
    switch(step) {
      case EditContentStep.type:
        return FontAwesomeIcons.plus;
      case EditContentStep.description:
        return FontAwesomeIcons.feather;
      case EditContentStep.price:
        return FontAwesomeIcons.coins;
      case EditContentStep.when:
        return FontAwesomeIcons.calendar;
      case EditContentStep.where:
        return FontAwesomeIcons.locationDot;
      case EditContentStep.multimedia:
        return FontAwesomeIcons.camera;
      case EditContentStep.tags:
        return FontAwesomeIcons.tag;
      case EditContentStep.links:
        return FontAwesomeIcons.link;
      case EditContentStep.preview:
        return FontAwesomeIcons.cloudArrowUp;
    }
  }

  static String getEditContentStepRoute(EditContentStep step){
    switch(step) {
      case EditContentStep.type:
        return editContentTypeRoute;
      case EditContentStep.description:
        return editContentDescriptionRoute;
      case EditContentStep.price:
        return editContentPriceRoute;
      case EditContentStep.when:
        return editContentWhenRoute;
      case EditContentStep.where:
        return editContentWhereRoute;
      case EditContentStep.multimedia:
        return editContentMultimediaRoute;
      case EditContentStep.tags:
        return editContentTagsRoute;
      case EditContentStep.links:
        return editContentSocialLinkRoute;
      case EditContentStep.preview:
        return editContentPreviewRoute;
    }
  }

  static EditContentStep getNextStep(EditContentStep step){
    EditContentStep? nextStep = EditContentStep.values.firstWhereOrNull((element) => element.index == step.index+1);
    nextStep ??= step;
    return nextStep;
  }

  static EditContentStep getPreviousStep(EditContentStep step){
    EditContentStep? nextStep = EditContentStep.values.firstWhereOrNull((element) => element.index == step.index-1);
    nextStep ??= step;
    return nextStep;
  }
}