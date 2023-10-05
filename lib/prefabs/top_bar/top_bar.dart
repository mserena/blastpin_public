import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_element.dart';
import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  final List<TopBarElement> elements;

  const TopBar({super.key, required this.elements});

  @override
  State<TopBar> createState() => TopBarState();
}

class TopBarState extends State<TopBar>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(225),
            Colors.transparent
          ],
        )
      ),
      width: MediaQuery.of(context).size.width,
      height: defTopBarHeigth,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _constructElements(TopBarPosition.left),
          _constructElements(TopBarPosition.center),
          _constructElements(TopBarPosition.right)
        ],
      )
    );
  }

  Widget _constructElements(TopBarPosition position){
    List<TopBarElement> elements = widget.elements.where((element) => element.position == position).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for(int idxElement = 0; idxElement < elements.length; idxElement++) ...{
          elements[idxElement].element,
        }
      ],
    );
  }
}