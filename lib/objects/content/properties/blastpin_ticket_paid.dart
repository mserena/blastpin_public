import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket.dart';
import 'package:blastpin/services/currency_manager.dart';

class BlastPinTicketPaid extends BlastPinTicket{
  String? areaId;
  int? price;
  String? shopLink;

  BlastPinTicketPaid() : super(type: TicketType.paid);

  @override
  void populateFromJson(Map<String,dynamic> json){
    if(json['areaId'] != null){
      areaId = json['areaId'];
    }

    if(json['price'] != null){
      price = json['price'];
    }

    if(json['shopLink'] != null){
      shopLink = json['shopLink'];
    }
  }

  @override
  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = super.toJson();
    if(areaId != null){
      json.putIfAbsent('areaId', () => areaId);
    }
    
    if(price != null){
      json.putIfAbsent('price', () => price);
    }
    
    if(shopLink != null){
      json.putIfAbsent('shopLink', () => shopLink);
    }
    return json;
  }

  @override
  bool isValidTicket(){
    return areaId != null && price != null && shopLink != null;
  }

  @override  
  String getPriceString(){
    String priceStr = '';
    if(price != null && areaId != null){
      priceStr = CurrencyManager().getTextFormatter(customAreaId: areaId).format(price.toString());
    }
    return priceStr;
  }

  @override
  String toString(){
    String superStr = super.toString();
    if(isValidTicket()){
      superStr += ', ticket price: ${price.toString()} on area: $areaId, buy it here: $shopLink';
    }
    return superStr;
  }
}