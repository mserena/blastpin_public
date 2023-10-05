import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/objects/content/view/content_view.dart';
import 'package:flutter/material.dart';

class ContentPlaceView extends ContentView {
  const ContentPlaceView({required Key key, required Content content, required double width}) : super(key: key, content: content, width: width);

  @override
  ContentPlaceViewState createState() => ContentPlaceViewState();
}

class ContentPlaceViewState extends ContentViewState<ContentView>{
  @override
  Widget buildWhen(){
    //ContentPlace place = widget.content as ContentPlace;
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //TODO: implement this.
          Container(),
          const SizedBox(height: 20),
        ]
      ),
    );
  }
}