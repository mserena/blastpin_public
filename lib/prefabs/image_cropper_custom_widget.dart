import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/icon_button.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/top_bar/top_bar.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImageCropperCustomWidget extends StatefulWidget {
  final Widget cropper;
  final Function crop;
  final Function? rotate;

  const ImageCropperCustomWidget({super.key, required this.cropper, required this.crop, this.rotate});

  @override
  State<ImageCropperCustomWidget> createState() => _ImageCropperCustomWidget();
}

class _ImageCropperCustomWidget extends State<ImageCropperCustomWidget>{
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, defTopBarHeigth+10, 0, 0),
              child: widget.cropper,
            ),
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
            icon: FontAwesomeIcons.xmark,
            onPress: (){
              Navigator.pop(context);
            }
          ),
          position: TopBarPosition.left
        ),
        TopBarElement(
          element: createIconButton(
            icon: FontAwesomeIcons.check,
            onPress: () async {
              setState(() {
                _isLoading = true; 
              });              
              final result = await widget.crop();
              setState(() {
                _isLoading = false;
                Navigator.pop(context,result); 
              });
            }
          ),
          position: TopBarPosition.right
        ),
      ],
    );
  }
}