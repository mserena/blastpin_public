import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/button_generic.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';

class SignInEmailPage extends StatefulWidget {
  const SignInEmailPage({super.key});

  @override
  State<SignInEmailPage> createState() => _SignInEmailPage();
}

class _SignInEmailPage extends State<SignInEmailPage> with AfterLayoutMixin<SignInEmailPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Email
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _emailTextController = TextEditingController();
  final GlobalKey<FormFieldState> _emailTextFormFieldKey  = GlobalKey<FormFieldState>();
  String? _email;

  @override
  void dispose() {
    _emailFocusNode.dispose();     
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    FocusScope.of(context).requestFocus(_emailFocusNode);
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
            _createSignInEmailView(),
            _createTopBar(),
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

  Widget _createSignInEmailView(){
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
                LanguageManager().getText('Email'),
                textAlign: TextAlign.center,
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineLarge!
              ),
              const SizedBox(height: 10),
              Text(
                LanguageManager().getText('Please, enter your valid e-mail. We will send to you a link for a passwordless Sign-In.'),
                textAlign: TextAlign.center,
                style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!
              ),
              const SizedBox(height: 35),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {                                        
                  return createInputDataBox(
                    textFormFieldKey: _emailTextFormFieldKey,
                    width: constraints.maxWidth,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Your valid e-mail',
                    textController: _emailTextController,
                    icon: FontAwesomeIcons.at,
                    focusNode: _emailFocusNode,
                    onChanged: _onEmailTextChanged
                  );
                }
              ),
              const SizedBox(height: 55),
              createButtonGeneric(
                'Continue',
                _onPressContinue,
                enabled: TextUtils.validateEmail(_email)
              ),
              const SizedBox(height: defTopBarHeigth*2),
            ],
          ),
        ),
      )
    );
  }

  void _onEmailTextChanged(String text){
    setState(() {
      _email = text;
    });
  }

  void _onPressContinue(){
    Map<String,String> userData = <String,String>{};
    userData.putIfAbsent('email', () => _email!);
    Navigator.pop(context,userData);
  }
}