import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/objects/content/view/content_view.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:flutter/material.dart';

class ContentEventView extends ContentView {
  const ContentEventView({required Key key, required Content content, required double width}) : super(key: key, content: content, width: width);

  @override
  ContentEventViewState createState() => ContentEventViewState();
}

class ContentEventViewState extends ContentViewState<ContentView>{
  @override
  Widget buildWhen(){
    ContentEvent event = widget.content as ContentEvent;
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              _buildDateTime(event.whenStart!,Theme.of(gNavigatorStateKey.currentContext!).textTheme.displayMedium!),
              Text(
                ' ${LanguageManager().getText('to')} ',
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
              ),
              _buildDateTime(event.whenEnd!,Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!),
            ],
          ),
          const SizedBox(height: 20),
        ]
      ),
    );
  }

  Widget _buildDateTime(DateTime datetime, TextStyle style){
    return FutureBuilder<String>(
      future: DateTimeUtils.getDateTimeFormattedLocale(datetime),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Text(
            snapshot.data!,
            style: style
          );
        } else {
          return Container();
        }
      }
    );
  }
}