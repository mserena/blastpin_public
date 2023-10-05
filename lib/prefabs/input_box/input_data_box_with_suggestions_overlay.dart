import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:flutter/material.dart';

class InputDataBoxWithSuggestionsOverlay extends StatefulWidget {
  final GlobalKey<FormFieldState> formKey;
  final TextEditingController textController;
  final FocusNode? focusNode;
  final double width;
  final String? hintText;
  final TextStyle? textStyle;
  final TextInputType? keyboardType;
  final IconData? icon;
  final Color? iconColor;
  final Function? onTextChanged;
  final Function? onPressSuggestion;

  const InputDataBoxWithSuggestionsOverlay(
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
  InputDataBoxWithSuggestionsOverlayState createState() => InputDataBoxWithSuggestionsOverlayState();
}

class InputDataBoxWithSuggestionsOverlayState extends State<InputDataBoxWithSuggestionsOverlay> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Map<String,String>? _suggestions;

  @override
  void initState() {
    super.initState();
  }

  void updateSuggestions(Map<String,String>? suggestions){
    if(_overlayEntry != null){
      _overlayEntry!.remove();
      _overlayEntry = null;
      //debugPrint('Suggestions menu removed.');
    }

    if(suggestions != null){
      _suggestions = suggestions;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      //debugPrint('Suggestions menu created.');
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject()! as RenderBox;
    var size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: <Widget>[
                if(_suggestions != null && _suggestions!.isNotEmpty) ...{
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
              ],
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: createInputDataBox(
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
      )
    );
  }
}