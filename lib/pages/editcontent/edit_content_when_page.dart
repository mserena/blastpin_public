import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/objects/content/content_place.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/editcontent/event_when_selector.dart';
import 'package:blastpin/prefabs/editcontent/place_when_selector.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentWhenPage extends StatefulWidget {
  const EditContentWhenPage({super.key});

  @override
  State<EditContentWhenPage> createState() => EditContentWhenPageState();
}

class EditContentWhenPageState extends State<EditContentWhenPage> with AfterLayoutMixin<EditContentWhenPage>, EditContent<EditContentWhenPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  //UI
  String _uiWhenText = '';

  EditContentWhenPageState(){
    step = EditContentStep.when;
  }

  @override
  void initState() {
    if(EditContentManager().getEditContent() != null){
      if(EditContentManager().getEditContent()!.type == ContentBlastPinType.event){
        _uiWhenText = 'When and how long will the event be.';
      } else if(EditContentManager().getEditContent()!.type == ContentBlastPinType.place){
        _uiWhenText = 'What days and hours is the place open?';
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            _createEditContentView(),
            createTopBarEditContent(context,setLoading,step),
            createBottomBarEditContent(context,_canContinue(),_onPressContinue),
            if(isLoading) ...{
              createBlockerLoading(context),
            }
          ],
        )
      )
    );
  }

  bool _canContinue(){
    bool canContinue = false;
    if(EditContentManager().getEditContent()!.type == ContentBlastPinType.event){
      ContentEvent content = EditContentManager().getEditContent() as ContentEvent;
      canContinue = content.whenStart != null && content.whenEnd != null && content.whenStart!.isBefore(content.whenEnd!);
    } else if(EditContentManager().getEditContent()!.type == ContentBlastPinType.place){
      if((EditContentManager().getEditContent() as ContentPlace).openingHours.isNotEmpty){
        if((EditContentManager().getEditContent() as ContentPlace).openingHours.firstWhereOrNull((day) => day.openTime.isAfter(day.closeTime)) == null){
          return true;
        }
      }
    }
    return canContinue;
  }

  void _onPressContinue() async{
    nextStep();
  }

  Widget _createEditContentView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    viewWidth = viewWidth - 20;
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(0, defTopBarHeigth, 0, 0),
        width: viewWidth,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            scrollbars: true,
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  createTitleAndSubtitle('When',_uiWhenText),
                  if(EditContentManager().getEditContent() != null) ...{
                    if(EditContentManager().getEditContent()!.type == ContentBlastPinType.event) ...{
                      EventWhenSelector(resfreshView: refreshView),
                    } else if(EditContentManager().getEditContent()!.type == ContentBlastPinType.place) ...{
                      PlaceWhenSelector(resfreshView: refreshView),
                    },
                  },
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          )
        ),
      )
    );
  }
}