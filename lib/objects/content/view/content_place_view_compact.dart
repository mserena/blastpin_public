import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/objects/content/view/content_view_compact.dart';
import 'package:flutter/material.dart';

class ContentPlaceViewCompact extends ContentViewCompact {
  const ContentPlaceViewCompact({Key? key, required Content content, required double width}) : super(key: key, content: content, width: width);

  @override
  ContentPlaceViewCompactState createState() => ContentPlaceViewCompactState();
}

class ContentPlaceViewCompactState extends ContentViewCompactState<ContentViewCompact>{
  @override
  Widget buildWhen(){
    return Container();
  }
}