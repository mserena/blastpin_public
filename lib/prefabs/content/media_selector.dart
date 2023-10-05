import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/alert_custom_button.dart';
import 'package:blastpin/prefabs/alerts/alert_dialog.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class MediaSelector extends StatefulWidget {
  final int id;
  final String name;
  final double size;
  final Function setLoading;
  final Function refreshView;

  const MediaSelector({required Key key, required this.id, required this.name, required this.size, required this.setLoading, required this.refreshView}) : super(key: key);

  @override
  State<MediaSelector> createState() => MediaSelectorState();
}

class MediaSelectorState extends State<MediaSelector>{
  
  @override
  void initState() {
    super.initState();
  }

  bool _haveContent(){
    if(EditContentManager().getEditContent() != null && widget.id < EditContentManager().getEditContent()!.media.length){
      return true;
    }else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _haveContent() ? _onTapFilledSelector : _onTapEmptySelector,
        child: DragTarget(
          onAccept: (data) {
            debugPrint('Item dragged from media selector $data to media selector ${widget.id}');
            XFile? file = EditContentManager().getEditContent()?.media[data as int];
            if(file != null){
              EditContentManager().addMediaToContent(widget.id,file);
              widget.refreshView();
            }
          },
          builder: (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ){
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: defBodyTextColor,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Stack(
                children: [
                  if(_haveContent()) ...{
                    _buildFilled(),
                  } else ...{
                    _buildEmpty(),
                  },
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(125),
                          borderRadius: const BorderRadius.all(Radius.circular(20))
                        ),
                        child: Text(
                          LanguageManager().getText(widget.name),
                          textAlign: TextAlign.left,
                          style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleSmall!
                        ),
                      ),
                    ),
                  )
                ],
              )
            );
          }
        )
      )
    );
  }

  Widget _buildEmpty(){
    return Center(
      child: Icon(
        FontAwesomeIcons.camera,
        color: defBackgroundPrimaryColor,
        size: ImageUtils.getIconSize(ObjectSize.big)
      ),
    );
  }

  Widget _buildFilled(){
    XFile? file = EditContentManager().getEditContent()?.media[widget.id];
    Widget fileWidget = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Image.network(
        file!.path,
        width: widget.size,
        height: widget.size,
      ), 
    );
    return Draggable(
      data: widget.id,
      feedback: fileWidget,
      childWhenDragging: Container(),
      child: fileWidget,
    );
  }

  void _onTapFilledSelector() async{
    await createAlertDialogOptions(
      context,
      [
        AlertCustomButton(
          text: 'Delete',
          identifier: UserActions.delete,
        ),
        AlertCustomButton(
          text: 'Omit',
          identifier: UserActions.omit,
          secondary: true
        )
      ],
      (option) {
        if(option == UserActions.delete){
          if(EditContentManager().getEditContent() != null){
            EditContentManager().getEditContent()?.media.removeAt(widget.id);
            widget.refreshView();
          }
        }
      },
      tapDismiss: true,
    ).show();
  }

  void _onTapEmptySelector() async{
    widget.setLoading(true);
    XFile? selectedFile = await ImageUtils.pickAndCropImage(context);
    if(selectedFile != null && EditContentManager().getEditContent() != null){
      EditContentManager().addMediaToContent(widget.id, selectedFile);
    }
    widget.setLoading(false);
  }
}