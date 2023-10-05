import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:flutter/material.dart';

class InputDataBoxWithSuggestionsWidget extends StatefulWidget {
  final GlobalKey<FormFieldState> formKey;
  final TextEditingController textController;
  final FocusNode? focusNode;
  final double width;
  final TextStyle? textStyle;
  final String? hintText;
  final TextInputType? keyboardType;
  final IconData? icon;
  final Color? iconColor;
  final Function? onTextChanged;
  final Function? onPressSuggestion;

  const InputDataBoxWithSuggestionsWidget(
    {
      super.key,
      required this.width,
      required this.formKey,
      required this.textController,
      this.focusNode,
      this.hintText,
      this.textStyle,
      this.keyboardType,
      this.icon,
      this.iconColor,
      this.onTextChanged,
      this.onPressSuggestion,
    }
  );

  @override
  InputDataBoxWithSuggestionsWidgetState createState() => InputDataBoxWithSuggestionsWidgetState();
}

class InputDataBoxWithSuggestionsWidgetState extends State<InputDataBoxWithSuggestionsWidget> {
  Map<String,String>? _suggestions;

  @override
  void initState() {
    super.initState();
  }

  void updateSuggestions(Map<String,String>? suggestions){
    setState(() {
      _suggestions = suggestions;
    });
  }

  Widget _createSuggestionsWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      width: widget.width,
      child: ListView(
        shrinkWrap: true,
        children: <Widget> [
          if(_suggestions != null) ...{
            if(_suggestions!.isNotEmpty) ...{
              for(int idxSuggestion = 0; idxSuggestion < _suggestions!.keys.length; idxSuggestion++) ...{
                ListTile(
                  hoverColor: Colors.white.withAlpha(50),
                  title: Text(
                    _suggestions![_suggestions!.keys.elementAt(idxSuggestion)]!,
                    style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
                  ),
                  onTap: () {
                    if(widget.onPressSuggestion != null){
                      widget.onPressSuggestion!(
                        _suggestions!.keys.elementAt(idxSuggestion),
                        _suggestions![_suggestions!.keys.elementAt(idxSuggestion)]!
                      );
                    }
                  },
                )
              }
            } else ...{
              ListTile(
                title: Text(
                  LanguageManager().getText('No results for this address.'),
                  style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
                ),
              ),
            }
          }
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return createInputDataBox(
      textFormFieldKey: widget.formKey,
      hintText: widget.hintText,
      textStyle: widget.textStyle,
      keyboardType: widget.keyboardType,
      textController: widget.textController,
      focusNode: widget.focusNode,
      width: widget.width,
      icon: widget.icon,
      iconColor: widget.iconColor,
      onChanged: widget.onTextChanged,
      extraWidget: _createSuggestionsWidget()
    );
  }
}