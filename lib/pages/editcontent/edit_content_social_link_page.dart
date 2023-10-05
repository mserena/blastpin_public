import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/editcontent/input_social_link.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/social_link_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentSocialLinkPage extends StatefulWidget {
  const EditContentSocialLinkPage({super.key});

  @override
  State<EditContentSocialLinkPage> createState() => EditContentSocialLinkPageState();
}

class EditContentSocialLinkPageState extends State<EditContentSocialLinkPage> with AfterLayoutMixin<EditContentSocialLinkPage>, EditContent<EditContentSocialLinkPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  EditContentSocialLinkPageState(){
    step = EditContentStep.links;
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
    bool canContinue = true;
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
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  const SizedBox(height: 30),
                  createTitleAndSubtitle('Social Links','Provide contact information and links to social networks to attract users and solve doubts.'),
                  const SizedBox(height: 20),
                  Wrap(
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var socialLinkType in SocialLinkType.values) ...{
                        createIconButton(
                          icon: SocialLinkUtils.getIcon(socialLinkType),
                          iconSize: ImageUtils.getIconSize(ObjectSize.big),
                          iconColor: EditContentManager().getEditContent()!.socialLinks.containsKey(socialLinkType) ? defBodyContrastTextColor : defBodyTextColor,
                          backgroundColor: EditContentManager().getEditContent()!.socialLinks.containsKey(socialLinkType) ? defPrimaryColor : defDisabledTextColor,
                          width: 100,
                          height: 100,
                          onPress: (){
                            _onPressSocialLink(socialLinkType);
                          }
                        ),
                      },
                    ]
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

  Future<void> _onPressSocialLink(SocialLinkType type) async{
    setLoading(true);
    String? link = await Navigator.of(context).push(
      InputSocialLinkRoute(
        inputType: type
      ) 
    );

    if(link != null){
      debugPrint('New link addeded to content: $link');
      EditContentManager().getEditContent()!.socialLinks.update(
        type, 
        (value) => value = link,
        ifAbsent: () => link,
      );
      await EditContentManager().storeEditContentDataLocal();
    }
    setLoading(false);
  }
}