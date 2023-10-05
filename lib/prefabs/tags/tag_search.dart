import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/tags/tag_view.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/services/tags_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TagSearchRoute extends ModalRoute<List<String>> {
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

  final int? maxTags;
  final List<String> originalSelectedTags;
  List<String> selectedTags = [];
  List<String> excludedTags = [];
  late final Future<List<String>> cloudTags = TagsManager().getTags();
  List<String> currentSearchTags = [];
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchTextController = TextEditingController();
  final GlobalKey<FormFieldState> _searchTextFormFieldKey  = GlobalKey<FormFieldState>();

  TagSearchRoute(
    {
      this.maxTags,
      this.originalSelectedTags = const [],
      this.excludedTags = const [],
    }
  ) {
    selectedTags = List<String>.from(originalSelectedTags);
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
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: defBackgroundPrimaryColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Text(
                        LanguageManager().getText('Cancel'),
                        style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.bodyMedium!,
                      ),
                      onTap: () {
                        Navigator.pop(context,originalSelectedTags);
                      },
                    ),
                    if(maxTags != null) ...{
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: LanguageManager().getText('Select'),
                              style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!
                            ),
                            TextSpan(
                              text: ' ${maxTags.toString()} ',
                              style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!,
                            ),
                            TextSpan(
                              text: LanguageManager().getText('tags.'),
                              style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.titleMedium!
                            ),
                          ],
                        ),
                      ),
                    },
                    InkWell(
                      child: Text(
                        LanguageManager().getText('Confirm'),
                        style: Theme.of(gNavigatorStateKey.currentContext!).textTheme.headlineMedium!,
                      ),
                      onTap: () {
                        Navigator.pop(context,selectedTags);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                createInputDataBox(
                  textFormFieldKey: _searchTextFormFieldKey,
                  width: MediaQuery.of(context).size.width,
                  keyboardType: TextInputType.text,
                  hintText: 'Tag name',
                  textController: _searchTextController,
                  focusNode: _searchFocusNode,
                  icon: FontAwesomeIcons.magnifyingGlass,
                  onChanged: (text){
                    setState(() { });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: createTagList(
                    tags: selectedTags,
                    canDelete: true,
                    enabled: true,
                    onTap: (tag){
                      selectedTags.remove(tag);
                      setState(() { });
                    }
                  ),
                ),
                const SizedBox(height: 20),
                Divider(
                  height: 10,
                  color: defDisabledTextColor,
                  thickness: 1,      
                ),
                const SizedBox(height: 30),
                FutureBuilder<List<String>>(
                  future: cloudTags,
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                    if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                      currentSearchTags = filterTags(snapshot.data!);
                      return SizedBox(
                        width: MediaQuery.of(context).size.width, 
                        child: createTagList(
                          tags: currentSearchTags,
                          canDelete: false,
                          enabled: false,
                          onTap: (tag){
                            if(maxTags == null || (maxTags != null && selectedTags.length < maxTags!)){
                              selectedTags.add(tag);
                              setState(() { });
                            }
                          }
                        )
                      );
                    } else {
                      return Center(
                        child: createLoadingIndicator(
                          size: ImageUtils.getAnimationSize(ObjectSize.normal)
                        )
                      );
                    }
                  }
                ),
              ],
            )
          );
        }
      )
    );
  }

  List<String> filterTags(List<String> allTags){
    List<String> currentTags = ListUtils.getElementsDifferentInBothList<String>(allTags,selectedTags);
    currentTags.removeWhere((tag) => excludedTags.contains(tag));
    if(_searchTextController.text != ''){
      currentTags.removeWhere(
        (tag) {
          String currentTagName = LanguageManager().getText(tag);
          return !currentTagName.toLowerCase().contains(_searchTextController.text.toLowerCase());
        }
      );
    }
    return currentTags;
  }
}
