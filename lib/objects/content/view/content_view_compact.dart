import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:flutter/material.dart';

class ContentViewCompact extends StatefulWidget {
  final double width;
  final Content content;

  const ContentViewCompact({super.key, required this.content, required this.width});

  @override
  State<ContentViewCompact> createState() => ContentViewCompactState();
}

class ContentViewCompactState<T extends ContentViewCompact> extends State<T> with AfterLayoutMixin<T> {
  //TODO: when content is loading media use isLoading
  //bool _isLoading = false;

  @override
  initState(){
    debugPrint('Build content of type ${widget.content.type.toString()} in compact view');
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    debugPrint('Content compact view after first layout.');
  }
  
  @override
  Widget build(BuildContext context) {
    double viewHeight = widget.width/2;
    double imageSize = (65*(viewHeight-20))/100;
    return SizedBox(
      width: widget.width,
      height: viewHeight,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: defBackgroundContentCompactColor,
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //TODO: overflow not work with Column
                //Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  //children: [
                    Flexible(
                      child: Text( 
                        widget.content.getLanguageString(defContentLanguageTitleKey)+'wwwww ngof fn',
                        style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    //buildWhen(),
                  //],
                //),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.network(
                      widget.content.media.first.path,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            )
          ],
        ) 
      )
    );
  }

  Widget buildWhen(){
    return Container();
  }
}