import 'package:after_layout/after_layout.dart';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/defines/theme.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket_free.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket_paid.dart';
import 'package:blastpin/pages/editcontent/edit_content.dart';
import 'package:blastpin/prefabs/editcontent/input_social_link.dart';
import 'package:blastpin/prefabs/bottom_bar/bottom_bar_add_content.dart';
import 'package:blastpin/prefabs/dropdown_button_box.dart';
import 'package:blastpin/prefabs/input_box/input_data_box.dart';
import 'package:blastpin/prefabs/loading_indicator.dart';
import 'package:blastpin/prefabs/title_subtitle.dart';
import 'package:blastpin/prefabs/top_bar/top_bar_add_content.dart';
import 'package:blastpin/services/content/edit_content_manager.dart';
import 'package:blastpin/services/currency_manager.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/utils/text_input_formatters/currency_textinputformatter.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:blastpin/utils/content_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditContentPricePage extends StatefulWidget {
  const EditContentPricePage({super.key});

  @override
  State<EditContentPricePage> createState() => EditContentPricePageState();
}

class EditContentPricePageState extends State<EditContentPricePage> with AfterLayoutMixin<EditContentPricePage>, EditContent<EditContentPricePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  BlastPinTicket _ticket = BlastPinTicketFree();

  //Paid ticket
  late CurrencyTextInputFormatter _currencyFormatter;
  final FocusNode _priceFocusNode = FocusNode();
  final GlobalKey<FormFieldState> _priceTextFormFieldKey  = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _shopLinkTextFormFieldKey  = GlobalKey<FormFieldState>();
  final TextEditingController _shopLinkTextController = TextEditingController();

  EditContentPricePageState(){
    step = EditContentStep.price;
  }

  @override
  void initState() {
    _priceFocusNode.addListener(() async {
      if(!_priceFocusNode.hasFocus && _ticket.type == TicketType.paid && (_ticket as BlastPinTicketPaid).price != null){
        await EditContentManager().storeEditContentDataLocal();
      }
    });
    if(EditContentManager().getEditContent() != null){
      _ticket = EditContentManager().getEditContent()!.ticket;
      if(_ticket.type == TicketType.paid){
        _shopLinkTextController.text = (_ticket as BlastPinTicketPaid).shopLink ?? '';
      }
    }
    _currencyFormatter = CurrencyManager().getTextFormatter();
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
    bool canContinue = _ticket.isValidTicket();
    return canContinue;
  }

  void _onPressContinue() async{
    setLoading(true);
    await EditContentManager().storeEditContentDataLocal();
    nextStep();
  }

  Widget _createEditContentView(){
    double viewWidth = MediaQuery.of(context).size.width < defMaxEditContentViewWidth ? MediaQuery.of(context).size.width : defMaxEditContentViewWidth;
    viewWidth = viewWidth - 20;
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(0, defTopBarHeigth, 0, 0),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  const SizedBox(height: 30),
                  createTitleAndSubtitle('Access','Indicate if a paid ticket is needed to access or if it is free.'),
                  const SizedBox(height: 10),
                  createDropdownButtonBox(
                    options: TicketType.values,
                    currentOption: _ticket.type,
                    customOptionTitles: ContentUtils.getTicketTitles(),
                    width: viewWidth,
                    iconLeft: FontAwesomeIcons.ticket,
                    onChanged: _onChangeTicketType
                  ),
                  if(_ticket.type == TicketType.paid) ...{
                    const SizedBox(height: 50),
                    createTitleAndSubtitle('Price','Set ticket price and purchase link to get it online.'),
                    const SizedBox(height: 10),
                    createInputDataBox(
                      textFormFieldKey: _priceTextFormFieldKey,
                      width: viewWidth,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        _currencyFormatter
                      ],
                      hintText: _currencyFormatter.format('1000'),
                      initialValue: (_ticket as BlastPinTicketPaid).getPriceString() != '' ? (_ticket as BlastPinTicketPaid).getPriceString() : null,
                      icon: FontAwesomeIcons.coins,
                      onChanged: _onChangeTicketPrice,
                      maxLength: 10,
                      showMaxLengthCounter: false
                    ),
                    const SizedBox(height: 30),
                    createInputDataBox(
                      textFormFieldKey: _shopLinkTextFormFieldKey,
                      textController: _shopLinkTextController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      width: viewWidth,
                      keyboardType: TextInputType.text,
                      hintText: 'https://www.ticket-shop.com',
                      icon: FontAwesomeIcons.shop,
                      onPress: _onPressShopLink,
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

  void _onChangeTicketPrice(String priceStr) async{
    if(_ticket.runtimeType != BlastPinTicketPaid){
      _ticket = BlastPinTicketPaid();
    }
    int price = TextUtils.getIntFromString(priceStr);
    (_ticket as BlastPinTicketPaid).price = price;
    (_ticket as BlastPinTicketPaid).areaId = MapManager().getMapCurrentArea().id;
    EditContentManager().getEditContent()!.ticket = _ticket;
    setState(() {});
  }

  void _onPressShopLink() async{
    setLoading(true);
    String? shopLink = await Navigator.of(context).push(
      InputSocialLinkRoute(
        inputType: SocialLinkType.website
      ) 
    );

    if(shopLink != null){
      debugPrint('Shop link addeded: $shopLink');
      if(_ticket.runtimeType != BlastPinTicketPaid){
        _ticket = BlastPinTicketPaid();
      }

      (_ticket as BlastPinTicketPaid).shopLink = shopLink;
      _shopLinkTextController.text = shopLink;
      EditContentManager().getEditContent()!.ticket = _ticket;
      await EditContentManager().storeEditContentDataLocal();
    }
    setLoading(false);
  }

  void _onChangeTicketType(TicketType type) async{
    setLoading(true);
    if(_ticket.type != type){
      switch(type) {
        case TicketType.free:
          _ticket = BlastPinTicketFree();
          break;
        case TicketType.paid:
          _ticket = BlastPinTicketPaid();
          break;
      }
      EditContentManager().getEditContent()!.ticket = _ticket;
      _shopLinkTextController.text = '';
      await EditContentManager().storeEditContentDataLocal();
    }
    setLoading(false);
  }
}