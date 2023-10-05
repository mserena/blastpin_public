import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/services/authentification_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/notification_manager.dart';
import 'package:blastpin/services/routes/route_definitions.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPage();
}

class _SignInPage extends State<SignInPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
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
            _createSignInView(),
            _createTopBar(),
            _createBottomView(),
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

  void _onPressBack(){
    Navigator.pop(context);
  }

  Widget _createBottomView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: defTopBarHeigth,
        width: MediaQuery.of(context).size.width,
        color: defBackgroundPrimaryColor,
        child: Container(
          color: Colors.white.withAlpha(25),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                      color: defBackgroundPrimaryColor,
                      height: 8,
                    ),
                    Container(
                      height: 2,
                      width: viewWidth,
                      color: defDisabledTextColor,
                    ),
                  ],
                )
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: viewWidth,
                  height: defTopBarHeigth,
                  child: Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${LanguageManager().getText('By continuing you accept the')} ',
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodySmall!
                          ),
                          TextSpan(
                            text: LanguageManager().getText('terms of use'),
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineSmall!,
                            recognizer: TapGestureRecognizer()..onTap = _onPressTermsOfUse
                          ),
                          TextSpan(
                            text: ' ${LanguageManager().getText('and')} ',
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodySmall!
                          ),
                          TextSpan(
                            text: LanguageManager().getText('privacy policy'),
                            style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineSmall!,
                            recognizer: TapGestureRecognizer()..onTap = _onPressPrivacyPolicy
                          ),
                        ],
                      ),
                    ), 
                  ),
                ) 
              )
            ],
          )  
        )
      )
    );
  }

  Widget _createSignInView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxSignInViewWidth ? MediaQuery.of(context).size.width : defMaxSignInViewWidth;
    return Center(
      child: Container(
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
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(), 
            children: [
              Text(
                LanguageManager().getText('Sign-In on BlastPin'),
                textAlign: TextAlign.center,
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineLarge!
              ),
              const SizedBox(height: 10),
              Text(
                LanguageManager().getText('Get an experience based on your interests, buy tickets, connect with people and more.'),
                textAlign: TextAlign.center,
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
              ),
              const SizedBox(height: 40),
              _createSignInButton(
                text: 'Continue with your E-mail',
                icon: FontAwesomeIcons.at,
                onPress: _onPressEmail,
              ),
              const SizedBox(height: 20),
              _createSignInButton(
                text: 'Continue with Google',
                icon: FontAwesomeIcons.google,
                onPress: _onPressGoogle,
              ),
              const SizedBox(height: 20),
              _createSignInButton(
                text: 'Continue with Facebook',
                icon: FontAwesomeIcons.facebook,
                onPress: _onPressFacebook,
              ),
              const SizedBox(height: defTopBarHeigth*2),
            ],
          ),
        ),
      )
    );
  }

  Widget _createSignInButton({required String text, required IconData icon, required Function onPress}){
    return createButtonGeneric(
      text,
      onPress,
      icon: icon,
      iconSize: ImageUtils.getIconSize(ObjectSize.normal)+2
    );
  }

  void _onPressTermsOfUse(){

  }

  void _onPressPrivacyPolicy(){

  }

  void _onPressEmail() async{
    setState(() {
      _isLoading = true;
    });

    dynamic pageData = await Navigator.pushNamed(
      context,
      signinEmailRoute
    );

    if(pageData != null && pageData['email'] != null){
      String email = pageData['email'];
      SignInOperationResult result = await AuthentificationManager().signInWithEmail(email);
      _processSignInResponse(result,EventType.eUserEmailLinkSent);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPressGoogle() async {
    setState(() {
      _isLoading = true;
    });
    SignInOperationResult result = await AuthentificationManager().signInWithGoogle();
    _processSignInResponse(result,EventType.eUserSignInEvent);
  }

  void _onPressFacebook() async{
    setState(() {
      _isLoading = true;
    });
    SignInOperationResult result = await AuthentificationManager().signInWithFacebook();
    _processSignInResponse(result,EventType.eUserSignInEvent);
  }

  void _processSignInResponse(SignInOperationResult result, EventType onDoneEvent) {
    switch(result){
      case SignInOperationResult.done:
        Navigator.pop(context,onDoneEvent);
        break;
      case SignInOperationResult.canceled:
        NotificationManager().addNotification(CustomNotificationType.signinCanceled);
        break;
      case SignInOperationResult.error:
        NotificationManager().addNotification(CustomNotificationType.signinError);
        break;
    }
    setState(() {
      _isLoading = false;
    });
  }
}