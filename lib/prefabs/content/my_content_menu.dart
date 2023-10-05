import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/objects/content/view/content_event_view_compact.dart';
import 'package:blastpin/objects/content/view/content_place_view_compact.dart';
import 'package:blastpin/prefabs/content/my_content_menu_filters.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyContentMenu extends StatefulWidget {
  final double widthView;

  const MyContentMenu({super.key, required this.widthView});

  @override
  State<MyContentMenu> createState() => MyContentMenuState();
}

class MyContentMenuState extends State<MyContentMenu>{
  bool _isLoading = false;

  //TODO: remove it's just for test
  final List<Content> _tmpContents = [];
  final ScrollController _scrollControllerContents = ScrollController();

  @override
  void initState() {
    if(EditContentManager().getEditContent() != null){
      for(int idxContent = 0; idxContent < 5; idxContent++){
        _tmpContents.add(EditContentManager().getEditContent()!);
      }
    }

    _scrollControllerContents.addListener(_scrollControllerContentsListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.widthView,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          _createMenuView(),
          _createActionButtons(),
          if(_isLoading) ...{
            //TODO: create specific loader for this listview
          }
        ],
      )
    );
  }

  Widget _createMenuView(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, defTopBarHeigth, 0, 0),
      child: Container(
        width: widget.widthView,
        height: MediaQuery.of(context).size.height-defTopBarHeigth,
        color: defBackgroundSecondaryColor,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            scrollbars: true,
          ),
          child: ListView.builder(
            controller: _scrollControllerContents,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            itemCount: _tmpContents.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: _createContentCompactView(_tmpContents[index],widget.widthView-20)
              );
            }
          )
        )
      ),
    );
  }

  Widget _createContentCompactView(Content content, double width){
    switch(content.type) {
      case ContentBlastPinType.event:
        return ContentEventViewCompact(content: content, width: width);
      case ContentBlastPinType.place:
        return ContentPlaceViewCompact(content: content, width: width);
    }
  }

  Widget _createActionButtons(){
    double iconSize = ImageUtils.getIconSize(ObjectSize.normal);
    double backgroundIconSize = iconSize + 25;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 40),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            createIconButton (
              icon: FontAwesomeIcons.sliders,
              iconColor: defBodyContrastTextColor,
              iconSize: iconSize,
              height: backgroundIconSize,
              width: backgroundIconSize,
              backgroundColor: defPrimaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              onPress: _onPressFilters,
            ),
          ]
        )
      ) 
    );
  }

  void _onPressFilters() async {
    await Navigator.of(context).push(
      MyContentMenuFilters(
        viewWidth: widget.widthView
      )
    );
  }

  void _scrollControllerContentsListener(){
    if (_scrollControllerContents.offset >= _scrollControllerContents.position.maxScrollExtent && !_scrollControllerContents.position.outOfRange) {
      //TODO: load more contents
    }
    //TODO: implement refresh contents
  }
}