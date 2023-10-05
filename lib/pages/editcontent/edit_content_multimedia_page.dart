import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/content/media_selector.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentMultimediaPage extends StatefulWidget {
  const EditContentMultimediaPage({super.key});

  @override
  State<EditContentMultimediaPage> createState() => EditContentMultimediaPageState();
}

class EditContentMultimediaPageState extends State<EditContentMultimediaPage> with AfterLayoutMixin<EditContentMultimediaPage>, EditContent<EditContentMultimediaPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final List<GlobalKey<MediaSelectorState>> _mediaSelectors = [];

  EditContentMultimediaPageState(){
    step = EditContentStep.multimedia;
  }

  @override
  void initState() {
    for(int idxMedia = 0; idxMedia < defMaxContentMediaFiles; idxMedia++){
      _mediaSelectors.add(GlobalKey<MediaSelectorState>());
    }
    super.initState();
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
    bool canContinue = false;
    if(EditContentManager().getEditContent() != null){
      canContinue = EditContentManager().getEditContent()!.media.isNotEmpty;
    }
    return canContinue;
  }

  void _onPressContinue(){
    nextStep();
  }

  Widget _createEditContentView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    viewWidth = viewWidth - 20;
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, defTopBarHeigth, 20, 0),
        alignment: Alignment.topCenter,
        width: viewWidth,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            scrollbars: false,
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
                  _createAddMedia(viewWidth),
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _createAddMedia(double viewWidth){
    // 60% of width for main media
    double paddingBetweenItems = 10;
    double mainMediaSize = (60*(viewWidth-20))/100;
    double extraMediaSize = (mainMediaSize/2) - (paddingBetweenItems/2);
    return Column(
      children: [
        createTitleAndSubtitle('Multimedia','Select some amazing photos that represent the event or place.'),
        Row(
          children: [
            _createMediaSelector(0,'Main',mainMediaSize),
            SizedBox(width: paddingBetweenItems),
            Column(
              children: [
                _createMediaSelector(1,'2',extraMediaSize),
                SizedBox(height: paddingBetweenItems),
                _createMediaSelector(2,'3',extraMediaSize),
              ],
            )
          ],
        ),
        SizedBox(height: paddingBetweenItems),
        Row(
          children: [
            _createMediaSelector(3,'4',extraMediaSize),
            SizedBox(width: paddingBetweenItems),
            _createMediaSelector(4,'5',extraMediaSize),
            SizedBox(width: paddingBetweenItems),
            _createMediaSelector(5,'6',extraMediaSize),
          ],
        ),
      ],
    );
  }

  Widget _createMediaSelector(int id, String name, double size){
    return MediaSelector(key: _mediaSelectors[id], id: id, name: name, size: size, setLoading: setLoading, refreshView: refreshView);
  }
}