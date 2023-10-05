import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/content/my_content_menu.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:blastpin/services/device_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyContentPage extends StatefulWidget {
  const MyContentPage({super.key});

  @override
  State<MyContentPage> createState() => MyContentPageState();
}

class MyContentPageState extends State<MyContentPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;

  MyContentPageState();

  @override
  void initState() {
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
            _createMyContentView(),
            TopBar(
              elements: [
                TopBarElement(
                  element: createIconButton(
                    icon: FontAwesomeIcons.arrowLeft,
                    onPress: (){
                       Navigator.pop(context);
                    }
                  ),
                  position: TopBarPosition.left
                ),
              ],
            ),
            if(_isLoading) ...{
              createBlockerLoading(context),
            }
          ],
        )
      )
    );
  }

  Widget _createMyContentView(){
    double menuWidth = 0;
    if(DeviceManager().getDeviceType() == DeviceType.mobile){
      menuWidth = MediaQuery.of(context).size.width;
    } else {
      menuWidth = defMinMyContentMenuView + defMinMyContentView <= MediaQuery.of(context).size.width ? defMinMyContentMenuView : MediaQuery.of(context).size.width;
    }

    return Positioned(
      top: 0,
      left: 0,
      child: MyContentMenu(
        widthView: menuWidth,
      ),
    );
  }
}