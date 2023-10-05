import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/tags/tag_search.dart';
import 'package:blastpin/prefabs/tags/tag_view.dart';
import 'package:blastpin/utils/list_utils.dart';
import 'package:flutter/material.dart';

class TagBox extends StatefulWidget {
  final double? width;
  final int? maxTags;
  final bool readOnly;
  final List<String> tags;
  final List<String> excludedTags;
  final Function? onTagListChanged;

  const TagBox(
    {
      super.key,
      this.width,
      this.maxTags,
      this.readOnly = true,
      this.tags = const [],
      this.excludedTags = const [],
      this.onTagListChanged,
    }
  );

  @override
  State<TagBox> createState() => TagBoxState();
}

class TagBoxState extends State<TagBox>{
  List<String> tags = [];

  @override
  void initState() {
    tags = List<String>.from(widget.tags);
    if(widget.maxTags != null && tags.length > widget.maxTags!){
      tags.removeRange(widget.maxTags!, tags.length);
    }
    tags = ListUtils.getElementsDifferentInBothList<String>(tags, widget.excludedTags);
    super.initState();
  }

  Future<void> _openSearchTag() async{
    List<String>? newTags = await Navigator.of(context).push(
      TagSearchRoute(
        maxTags: widget.maxTags,
        originalSelectedTags: tags,
        excludedTags: widget.excludedTags
      )
    );

    if(newTags != null){
      debugPrint('${newTags.length.toString()} tags selected.');
      tags = newTags;
      if(widget.onTagListChanged != null){
        widget.onTagListChanged!(tags);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: !widget.readOnly ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () async{
          if(!widget.readOnly){
            if(widget.maxTags == null || (widget.maxTags != null && tags.length < widget.maxTags!)){
              await _openSearchTag();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          width: widget.width,
          constraints: const BoxConstraints(
            minHeight: 55,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: defPrimaryColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: createTagList(
            tags: tags,
            canDelete: !widget.readOnly,
            showInfo: !widget.readOnly && (widget.maxTags == null ||  tags.length < widget.maxTags!),
            onTap: (tag) {
              tags.remove(tag);
              if(widget.onTagListChanged != null){
                widget.onTagListChanged!(tags);
              }
            }
          ),
        )
      )
    );
  }
}