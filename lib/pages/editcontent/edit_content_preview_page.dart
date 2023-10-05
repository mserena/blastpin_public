import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/view/content_view.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentPreviewPage extends StatefulWidget {
  const EditContentPreviewPage({super.key});

  @override
  State<EditContentPreviewPage> createState() => EditContentPreviewPageState();
}

class EditContentPreviewPageState extends State<EditContentPreviewPage> with AfterLayoutMixin<EditContentPreviewPage>, EditContent<EditContentPreviewPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  EditContentPreviewPageState(){
    step = EditContentStep.preview;
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
            createBottomBarEditContent(context,true,_onPressPublish, text: 'Publish'),
            if(isLoading) ...{
              createBlockerLoading(
                context,
                text: LanguageManager().getText('Publishing, please, don\'t close or refresh the page.'),
              ),
            }
          ],
        )
      )
    );
  }

  void _onPressPublish() async{
    setLoading(true);
    bool result = await EditContentManager().publish();
    if(result){
      //TODO: go to home view or my contents
    } 
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  const SizedBox(height: 30),
                  EditContentManager().getEditContent()!.createView(GlobalKey<ContentViewState>(),viewWidth),
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}