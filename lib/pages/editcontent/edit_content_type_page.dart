import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/alerts/alert_dialog.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/routes/route_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentTypePage extends StatefulWidget {
  const EditContentTypePage({super.key});

  @override
  State<EditContentTypePage> createState() => EditContentTypePageState();
}

class EditContentTypePageState extends State<EditContentTypePage> with AfterLayoutMixin<EditContentTypePage>, EditContent<EditContentTypePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  
  //Content
  ContentBlastPinType? _contentType;

  EditContentTypePageState(){
    step = EditContentStep.type;
  }

  @override
  void initState() {
    if(EditContentManager().getEditContent() != null){
      _contentType = EditContentManager().getEditContent()!.type;
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
            createBottomBarEditContent(context,_contentType != null,_onPressContinue),
            if(isLoading) ...{
              createBlockerLoading(context),
            }
          ],
        )
      )
    );
  }

  void _onPressContinue() async{
    setLoading(true);

    //Check if it's content type change
    if(EditContentManager().getEditContent() != null){
      if(EditContentManager().getEditContent()!.haveData() && _contentType != EditContentManager().getEditContent()!.type){
        bool? response = await createAlertDialogYesNot(
          context,
          title: LanguageManager().getText('Change Type?'),
          desc: LanguageManager().getText('If you change the type, you will lose all current data.')
        ).show();

        if(response != null && response){
          EditContentManager().cleanEditContent();
          if(!await EditContentManager().createEditContent(_contentType!)){
            RouteManager().popUntilHome();
            return;
          }
        } else {
          setState(() {
            isLoading = false;
            _contentType = EditContentManager().getEditContent()!.type;
          });
          return;
        }
      } else {
        EditContentManager().getEditContent()!.type = _contentType!;
      }
    } else {
      if(!await EditContentManager().createEditContent(_contentType!)){
        RouteManager().popUntilHome();
        return;
      }
    }
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      LanguageManager().getText('What do you want to add?'),
                      textAlign: TextAlign.left,
                      style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleLarge!
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${LanguageManager().getText('Select between event or place. Please, read')} ',
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
                          ),
                          TextSpan(
                            text: LanguageManager().getText('what we accept in BlastPin'),
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
                            recognizer: TapGestureRecognizer()..onTap = _onPressWhatWeAccept
                          ),
                          TextSpan(
                            text: ' ${LanguageManager().getText('before submitting your proposal. Events or places that don\'t fit our philosophy will not be published.')}',
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  createButtonGeneric(
                    'Event',
                    (){
                      _onSelectType(ContentBlastPinType.event,true);
                    },
                    icon: ImageUtils.getContentTypeIcon(ContentBlastPinType.event),
                    iconSize: ImageUtils.getIconSize(ObjectSize.normal)+2,
                    enabled: _contentType != null && _contentType == ContentBlastPinType.event,
                    onPressDisabled: (){
                      _onSelectType(ContentBlastPinType.event,false);
                    }
                  ),
                  const SizedBox(height: 20),
                  createButtonGeneric(
                    'Place',
                    (){
                      _onSelectType(ContentBlastPinType.place,true);
                    },
                    icon: ImageUtils.getContentTypeIcon(ContentBlastPinType.place),
                    iconSize: ImageUtils.getIconSize(ObjectSize.normal)+2,
                    enabled: _contentType != null && _contentType == ContentBlastPinType.place,
                    onPressDisabled: (){
                      _onSelectType(ContentBlastPinType.place,false);
                    }
                  ),
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  void _onPressWhatWeAccept(){
    //TODO: do view what and we accept
  }

  void _onSelectType(ContentBlastPinType type, bool enabled){
    setState(() {
      if(!enabled){
        _contentType = type;
      } else {
        _contentType = null;
      }
    });
  }
}