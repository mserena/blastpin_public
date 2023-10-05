import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/tags/tag_box.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentTagsPage extends StatefulWidget {
  const EditContentTagsPage({super.key});

  @override
  State<EditContentTagsPage> createState() => EditContentTagsPageState();
}

class EditContentTagsPageState extends State<EditContentTagsPage> with AfterLayoutMixin<EditContentTagsPage>, EditContent<EditContentTagsPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  String? mainTag;
  List<String> extraTags = [];

  EditContentTagsPageState(){
    step = EditContentStep.tags;
  }

  @override
  void initState() {
    if(EditContentManager().getEditContent() != null){
      mainTag = EditContentManager().getEditContent()!.mainTag;
      extraTags = EditContentManager().getEditContent()!.extraTags;
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
            createTopBarEditContent(context, setLoading, step),
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
    bool canContinue = mainTag != null;
    return canContinue;
  }

  void _onPressContinue() async{
    setLoading(true);
    await _updateEditContent();
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
                  createTitleAndSubtitle('Main Tag','Select one tag that best describes what it is about.'),
                  const SizedBox(height: 10),
                  TagBox(
                    width: viewWidth,
                    maxTags: 1,
                    readOnly: false,
                    tags: mainTag != null ? [mainTag!] : [],
                    excludedTags: extraTags,
                    onTagListChanged: (List<String> tags){
                      if(tags.isNotEmpty){
                        mainTag = tags.first;
                      } else {
                        mainTag = null;
                      }
                      _updateEditContent();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 30),
                  createTitleAndSubtitle('Extra Tags','Complete with up to eight extra tags that help to better understand what it is about.'),
                  const SizedBox(height: 10),
                  TagBox(
                    width: viewWidth,
                    maxTags: 8,
                    readOnly: false,
                    tags: extraTags,
                    excludedTags: mainTag != null ? [mainTag!] : [],
                    onTagListChanged: (List<String> tags){
                      extraTags = tags;
                      _updateEditContent();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          )
        ),
      )
    );
  }

  Future<void> _updateEditContent() async{
    debugPrint('call to update content.');
    if(EditContentManager().getEditContent() != null){
      bool changes = false;
      if(EditContentManager().getEditContent()!.mainTag != mainTag){
        EditContentManager().getEditContent()!.mainTag = mainTag;
        changes = true;
      }
      if(EditContentManager().getEditContent()!.extraTags != extraTags){
        EditContentManager().getEditContent()!.extraTags = extraTags;
        changes = true;
      }
      if(changes){
        await EditContentManager().storeEditContentDataLocal();
      }
    }
  }
}