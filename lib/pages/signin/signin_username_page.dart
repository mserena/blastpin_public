import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/alerts/alert_dialog.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/services/authentification_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/notification_manager.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:blastpin/services/routes/route_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';

class SignInUsernamePage extends StatefulWidget {
  const SignInUsernamePage({super.key});

  @override
  State<SignInUsernamePage> createState() => _SignInUsernamePage();
}

class _SignInUsernamePage extends State<SignInUsernamePage> with AfterLayoutMixin<SignInUsernamePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  //Username
  final FocusNode _usernameFocusNode = FocusNode();
  final TextEditingController _usernameTextController = TextEditingController();
  final GlobalKey<FormFieldState> _usernameTextFormFieldKey  = GlobalKey<FormFieldState>();
  String? _username;

  @override
  void dispose() {
    _usernameFocusNode.dispose();     
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    FocusScope.of(context).requestFocus(_usernameFocusNode);
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
            _createSignInUsernameView(),
            _createTopBar(),
            if(_isLoading) ...{
              createBlockerLoading(context),
            }
          ],
        )
      )
    );
  }

  Widget _createTopBar(){
    return TopBar(
      elements: [
        TopBarElement(
          element: createIconButton(
            icon: FontAwesomeIcons.arrowLeft,
            onPress: _onPressBack
          ),
          position: TopBarPosition.left
        ),
      ],
    );
  }

  void _onPressBack() async{
    bool? response = await createAlertDialogYesNot(
      context,
      title: LanguageManager().getText('Cancel Sign-In?'),
      desc: LanguageManager().getText('If you leave now, your sign-in will be canceled.')
    ).show();
    if(response != null && response){
      setState(() {
        RouteManager().popUntilHome(context: context);
      });
    }
  }

  Widget _createSignInUsernameView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxSignInViewWidth ? MediaQuery.of(context).size.width : defMaxSignInViewWidth;
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, defTopBarHeigth, 20, 0),
        width: viewWidth,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
            scrollbars: false,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(), 
            children: [
              Text(
                LanguageManager().getText('Your name'),
                textAlign: TextAlign.center,
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineLarge!
              ),
              const SizedBox(height: 10),
              Text(
                LanguageManager().getText('We will use your name for tickets and social experience.'),
                textAlign: TextAlign.center,
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
              ),
              const SizedBox(height: 35),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {                                        
                  return createInputDataBox(
                    textFormFieldKey: _usernameTextFormFieldKey,
                    width: constraints.maxWidth,
                    keyboardType: TextInputType.text,
                    hintText: 'Your name and surname',
                    textController: _usernameTextController,
                    icon: FontAwesomeIcons.user,
                    focusNode: _usernameFocusNode,
                    onChanged: _onUsernameTextChanged
                  );
                }
              ),
              const SizedBox(height: 55),
              createButtonGeneric(
                'Continue',
                _onPressContinue,
                enabled: TextUtils.validateUsername(_username)
              ),
              const SizedBox(height: defTopBarHeigth*2),
            ],
          ),
        ),
      )
    );
  }

  void _onUsernameTextChanged(String text){
    setState(() {
      _username = text;
    });
  }

  void _onPressContinue() async {
    setState(() {
      _isLoading = true;
    });
    SignInOperationResult result = await AuthentificationManager().completeSignInWithEmail(_username!);
    switch(result){
      case SignInOperationResult.done:
        setState(() {
          _isLoading = false;
          RouteManager().popUntilHome(context: context);
          Navigator.pushNamedAndRemoveUntil(context,homeRoute,(Route<dynamic> route) => false, arguments: EventType.eUserSignInEvent);
        }); 
        break;
      case SignInOperationResult.error:
      case SignInOperationResult.canceled:
        NotificationManager().addNotification(CustomNotificationType.signinError);
        setState(() {
          _isLoading = false;
        }); 
        break;
    }
  }
}