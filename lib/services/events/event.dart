import 'dart:async';
import 'package:blastpin/defines/globals.dart';

class EventData{
  EventType type;
  Map<String,dynamic>? data;

  EventData(this.type, this.data);
}

class Event{
  EventType type;
  final StreamController _controller = StreamController.broadcast();
  final List<StreamSubscription> _listeners = [];

  Event(this.type);

  dispose(){
    for(int idxListener = 0; idxListener < _listeners.length; idxListener++){
      _listeners[idxListener].cancel();
    }
    _listeners.clear();
    _controller.close();
  }

  launch(dynamic data){
    EventData e = EventData(type,data);
    _controller.add(e);
  }

  StreamSubscription subscribe(Function onEvent){
    StreamSubscription subscription = _controller.stream.listen((data) {
      onEvent(data);
    });
    _listeners.add(subscription);
    return subscription;
  }

  void unsubscribe(StreamSubscription subscription){
    if(haveSubscription(subscription)){
      subscription.cancel();
      _listeners.remove(subscription);
    }
  }

  bool haveSubscription(StreamSubscription subscription){
    return _listeners.contains(subscription);
  }

  String info(){
    return 'event ${type.toString()} have ${_listeners.length.toString()} active subscriptions.';
  }
}