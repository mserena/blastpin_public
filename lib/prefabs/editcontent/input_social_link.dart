import 'dart:async';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/social_link_utils.dart';
import 'package:flutter/material.dart';

class InputSocialLinkRoute extends ModalRoute<String> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.2);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  String? _inputText;
  final String? originalText;
  final SocialLinkType inputType;
  Timer? _validateSocialLinkDelay;
  bool _isValidating = false;
  String? _currentError;
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _inputTextController = TextEditingController();
  final GlobalKey<FormFieldState> _inputTextFormFieldKey  = GlobalKey<FormFieldState>();

  InputSocialLinkRoute(
    {
      required this.inputType,
      this.originalText
    }
  );

  @override
  void dispose() {
    if(_validateSocialLinkDelay != null){
      _validateSocialLinkDelay!.cancel();
    }
    super.dispose();
  }

  @override
  Widget buildTransitions( BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Material(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: defBackgroundPrimaryColor,
            child: Column(
              children: [
                SizedBox(
                  height: defTopBarHeigth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Text(
                          LanguageManager().getText('Cancel'),
                          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
                        ),
                        onTap: () {
                          Navigator.pop(context,null);
                        },
                      ),
                      if(_isValidating) ...{
                        createLoadingIndicator(
                          size: ImageUtils.getAnimationSize(ObjectSize.small)
                        ),
                      } else ...{
                        InkWell(
                          child: Text(
                            LanguageManager().getText('Confirm'),
                            style: _inputText != null ? Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium! : Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!,
                          ),
                          onTap: () {
                            Navigator.pop(context,_inputText);
                          },
                        )
                      }
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                createInputDataBox(
                  autofocus: true,
                  textFormFieldKey: _inputTextFormFieldKey,
                  width: MediaQuery.of(context).size.width,
                  hintText: SocialLinkUtils.getHintText(inputType),
                  textController: _inputTextController,
                  focusNode: _inputFocusNode,
                  icon: SocialLinkUtils.getIcon(inputType),
                  keyboardType: SocialLinkUtils.getInputKeyboard(inputType),
                  error: _currentError,
                  onChanged: (text){
                    _validateSocialLinkDelayed(setState);
                  }
                )
              ],
            )
          );
        }
      )
    );
  }

  void _validateSocialLinkDelayed(StateSetter setState){
    if(_validateSocialLinkDelay != null){
      _validateSocialLinkDelay!.cancel();
    }

    setState(() {
      _isValidating = true;
      _currentError = null;
    });
    _validateSocialLinkDelay = Timer.periodic(defDelayUserInput, (Timer t) => _validateSocialLink(setState));
  }

  Future<void> _validateSocialLink(StateSetter setState) async {
    if(_validateSocialLinkDelay != null){
      _validateSocialLinkDelay!.cancel();
    }

    setState(() {
      _isValidating = true;
      _currentError = null;
    });

    try{
      String link = _inputTextController.text;
      if(SocialLinkUtils.validateLinkFormat(inputType, link)){
        debugPrint('$link have good format for ${inputType.toString()}');
        if(await SocialLinkUtils.validateLinkExist(inputType, link)){
          _inputText = link;
        } else {
          _currentError = SocialLinkUtils.getErrorTextNotOnline(inputType);
        }
      } else {
        _inputText = null;
        _currentError = SocialLinkUtils.getErrorTextNotValidFormat(inputType);
      }
    }catch(e){
      debugPrint('Error on function _validateSocialLink: ${e.toString()}');
      _currentError = 'Something went wrong. Try again later.';
    }

    setState(() {
      _isValidating = false;
    });
  }
}
