import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/blastpin_currency.dart';
import 'package:blastpin/objects/settings/map_settings.dart';
import 'package:blastpin/services/map_manager.dart';
import 'package:blastpin/utils/text_input_formatters/currency_textinputformatter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CurrencyManager{
  late BlastPinCurrency _currency;

  // Singleton
  static final CurrencyManager _instance = CurrencyManager._internal();

  factory CurrencyManager(){
    return _instance;
  }

  CurrencyManager._internal();

  init() {
    setCurrentCurrency(); 
  }

  void setCurrentCurrency(){
    String areaCurrencyCode = MapManager().getMapCurrentArea().currency;
    BlastPinCurrency? areaCurrency = defCurrencies.firstWhereOrNull((currency) => currency.code == areaCurrencyCode);
    areaCurrency ??= defCurrencies.firstWhere((currency) => currency.code == defDefaultCurrency);
    _currency = areaCurrency;
    debugPrint('Currency set to ${_currency.toString()}');
  }

  CurrencyTextInputFormatter getTextFormatter({String? customAreaId}){
    BlastPinCurrency currencyAux = _currency;
    String locale = MapManager().getMapCurrentArea().locale;
    if(customAreaId != null){
      MapArea? customArea = MapManager().getMapArea(customAreaId);
      if(customArea != null){
        BlastPinCurrency? customCurrency = defCurrencies.firstWhereOrNull((currency) => currency.code == customArea.currency);
        if(customCurrency != null){
          currencyAux = customCurrency;
          locale = customArea.locale;
        }
      }
    }

    return CurrencyTextInputFormatter(
      locale: locale,
      decimalDigits: 2,
      symbol: currencyAux.symbol,
      enableNegative: false
    );
  }

  BlastPinCurrency getCurrentCurrency(){
    return _currency;
  }
}