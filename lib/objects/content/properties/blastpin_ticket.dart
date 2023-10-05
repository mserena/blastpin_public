import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket_free.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket_paid.dart';
import 'package:blastpin/utils/text_utils.dart';

class BlastPinTicket {
  TicketType type;

  BlastPinTicket(
    {
    required this.type, 
    }
  );

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = <String,dynamic>{};
    json.putIfAbsent('type', () => type.toString());
    return json;
  }

  void populateFromJson(Map<String,dynamic> json){

  }

  factory BlastPinTicket.fromJson(Map<String,dynamic> json){
    TicketType type = TextUtils.enumFromString(TicketType.values,json['type'])!;
    BlastPinTicket fromJsonTicket;
    switch(type) {
      case TicketType.free:
        fromJsonTicket = BlastPinTicketFree();
        break;
      case TicketType.paid:
        fromJsonTicket = BlastPinTicketPaid();
        break;
    }
    fromJsonTicket.populateFromJson(json);
    return fromJsonTicket;
  }

  bool isValidTicket(){
    return true;
  }

  String getPriceString(){
    return '';
  }

  @override
  String toString(){
    return 'Ticket ${type.toString()}';
  }
}