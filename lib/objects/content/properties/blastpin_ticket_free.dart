import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/properties/blastpin_ticket.dart';
import 'package:blastpin/services/language_manager.dart';

class BlastPinTicketFree extends BlastPinTicket{
  BlastPinTicketFree() : super(type: TicketType.free);

  @override  
  String getPriceString(){
    return LanguageManager().getText('Free');
  }
}