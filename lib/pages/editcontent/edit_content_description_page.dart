import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/flag.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/language_manager.dart';
import 'package:blastpin/utils/image_utils.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EditContentDescriptionLanguageData{
  //Title
  final FocusNode titleFocusNode = FocusNode();
  final TextEditingController titleTextController = TextEditingController();
  final GlobalKey<FormFieldState> titleTextFormFieldKey  = GlobalKey<FormFieldState>();

  //Description
  final FocusNode descriptionFocusNode = FocusNode();
  final TextEditingController descriptionTextController = TextEditingController();
  final GlobalKey<FormFieldState> descriptionTextFormFieldKey  = GlobalKey<FormFieldState>();

  void dispose(){
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
  }
}

class EditContentDescriptionPage extends StatefulWidget {
  const EditContentDescriptionPage({super.key});

  @override
  State<EditContentDescriptionPage> createState() => EditContentDescriptionPageState();
}

class EditContentDescriptionPageState extends State<EditContentDescriptionPage> with AfterLayoutMixin<EditContentDescriptionPage>, EditContent<EditContentDescriptionPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  Timer? _storeLanguagesDelay;
  
  //UI
  String _uiTitleText = '';
  String _uiDescriptionText = '';

  //Language
  String _currentLanguageCode = defDefaultLanguage;

  //Forms
  final Map<String,EditContentDescriptionLanguageData> _data = <String,EditContentDescriptionLanguageData>{};

  EditContentDescriptionPageState(){
    step = EditContentStep.description;
  }

  @override
  void initState() {
    _currentLanguageCode = LanguageManager().getCurrentLanguage();
    for(int idxLanguage = 0; idxLanguage < defDefaultLanguagesList.length; idxLanguage++){
      String isoCode = defDefaultLanguagesList[idxLanguage]['isoCode'];
      _data.putIfAbsent(isoCode, () => EditContentDescriptionLanguageData());
    }

    Map<String,Map<String,String>> editContentLanguages = EditContentManager().getEditContent()!.languages;
    if(editContentLanguages.isNotEmpty){
      editContentLanguages.forEach((key,value){
        if(_data.containsKey(key)){
          _data[key]!.titleTextController.text = value.containsKey('Title') ? value['Title']! : '';
          _data[key]!.descriptionTextController.text = value.containsKey('Description') ? value['Description']! : '';
        }
      }); 
    }

    String type = TextUtils.stringFromEnum(EditContentManager().getEditContent()!.type);
    _uiTitleText = 'Choose a short and catchy title that describes the $type.';
    _uiDescriptionText = 'Explain what makes this $type so special.';
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if(_data.containsKey(_currentLanguageCode)){
      FocusScope.of(context).requestFocus(_data[_currentLanguageCode]!.titleFocusNode);
    }
    super.afterFirstLayout(context);
  }

  @override
  void dispose() {
    for(EditContentDescriptionLanguageData data in _data.values) {
      data.dispose();
    }   
    super.dispose();
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
            _createEditContentView(),
            createTopBarEditContent(context, setLoading, step),
            createBottomBarEditContent(context,_canContinue(),_onPressContinue),
            if(isLoading) ...{
              createBlockerLoading(context),
            }
          ],
        )
      )
    );
  }

  bool _canContinue(){
    bool canContinue = false;
    if(_data.isNotEmpty){
      _data.forEach((key,value){
        if(_data[key]!.titleTextController.text.isNotEmpty && 
          _data[key]!.descriptionTextController.text.isNotEmpty){
            canContinue = true;
        }
      }); 
    }
    return canContinue;
  }

  void _onPressContinue() async{
    setState(() {
      isLoading = true;
    });
    await _storeLanguages();
    nextStep();
  }

  Widget _createEditContentView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    viewWidth = viewWidth - 20;
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
            scrollbars: true,
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0), 
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _createLanguageSelector(),
                  const SizedBox(height: 40),
                  if(_data.containsKey(_currentLanguageCode)) ...{
                    createTitleAndSubtitle('Title',_uiTitleText),
                    createInputDataBox(
                      textFormFieldKey: _data[_currentLanguageCode]!.titleTextFormFieldKey,
                      width: viewWidth,
                      keyboardType: TextInputType.text,
                      hintText: 'Write some words',
                      textController: _data[_currentLanguageCode]!.titleTextController,
                      focusNode: _data[_currentLanguageCode]!.titleFocusNode,
                      onChanged: _onTitleTextChanged,
                      maxLength: defMaxTitleLength,
                    ),
                    const SizedBox(height: 40),
                    createTitleAndSubtitle('Description',_uiDescriptionText),
                    createInputDataBox(
                      textFormFieldKey: _data[_currentLanguageCode]!.descriptionTextFormFieldKey,
                      width: viewWidth,
                      keyboardType: TextInputType.multiline,
                      hintText: 'Write some words',
                      textController: _data[_currentLanguageCode]!.descriptionTextController,
                      focusNode: _data[_currentLanguageCode]!.descriptionFocusNode,
                      onChanged: _onDescriptionTextChanged,
                      maxLength: defMaxDescriptionLength,
                      maxLines: null
                    ),
                  },
                  const SizedBox(height: defTopBarHeigth*2),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget _createLanguageSelector(){
    return SizedBox(
      height: ImageUtils.getFlagSize(ObjectSize.normal,context: context).height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: defDefaultLanguagesList.length,
        itemBuilder: (context, index) {
          String isoCode = defDefaultLanguagesList[index]['isoCode'];
          String flagName = defDefaultLanguagesList[index]['flag'];
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            width: ImageUtils.getFlagSize(ObjectSize.normal,context: context).width,
            height: ImageUtils.getFlagSize(ObjectSize.normal,context: context).height,
            child: Flag.fromString(
              isoCode,
              flagName,
              fit: BoxFit.fill,
              borderRadius: 10,
              onPress: _onChangeLanguage,
              selected: isoCode == _currentLanguageCode,
            )
          );
        },
      )
    );
  }

  void _onChangeLanguage(String isoCode){
    setState(() {
      _currentLanguageCode = isoCode;
    });
  }

  void _onTitleTextChanged(String text){
    _storeLanguagesDelayed();
    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
  }

  void _onDescriptionTextChanged(String text){
    _storeLanguagesDelayed();
    if(_data.containsKey(_currentLanguageCode) && _data[_currentLanguageCode]!.descriptionTextController.selection.base.offset == text.length){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _storeLanguagesDelayed(){
    if(_storeLanguagesDelay != null){
      _storeLanguagesDelay!.cancel();
    }
    _storeLanguagesDelay = Timer.periodic(defDelayStoreLanguages, (Timer t) => _storeLanguages());
    setState(() {});
  }

  Future<void> _storeLanguages() async{
    if(_storeLanguagesDelay != null){
      _storeLanguagesDelay!.cancel();
    }

    if(EditContentManager().getEditContent() != null){
      bool changes = false;

      for(String isoCode in _data.keys) {
        String? title = _data[isoCode]!.titleTextController.text;
        String? description = _data[isoCode]!.descriptionTextController.text;
        if(title.isNotEmpty || description.isNotEmpty){
          dynamic language = {
            defContentLanguageTitleKey : title,
            defContentLanguageDescriptionKey : description
          };
          if(await EditContentManager().addLanguage(isoCode, language, store: false)){
            changes = true;
          }
        }
      }

      if(changes){
        EditContentManager().storeEditContentDataLocal();
      }
    }
  }
}