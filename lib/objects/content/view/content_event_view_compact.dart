import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/objects/content/view/content_view_compact.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:flutter/material.dart';

class ContentEventViewCompact extends ContentViewCompact {
  const ContentEventViewCompact({Key? key, required Content content, required double width}) : super(key: key, content: content, width: width);

  @override
  ContentEventViewCompactState createState() => ContentEventViewCompactState();
}

class ContentEventViewCompactState extends ContentViewCompactState<ContentViewCompact>{
  @override
  Widget buildWhen(){
    ContentEvent event = widget.content as ContentEvent;
    return Flexible(
      child: DateTimeUtils.buildDateTimeWithStyle(
        event.whenStart!,
        Theme.of(gNavigatorStateKey.currentContext!).textTheme.displayMedium!,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}