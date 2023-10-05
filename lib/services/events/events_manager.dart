import 'dart:async';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/events/event.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class EventsManager{
  // Events
  final List<Event> _events = [];

  // Singleton
  static final EventsManager _instance = EventsManager._internal();

  factory EventsManager(){
    return _instance;
  }

  EventsManager._internal() {
    for (var type in EventType.values) {
       _addEvent(type);
    }
  }

  dispose(){
    for (var type in EventType.values) {
       _removeEvent(type);
    }
  }

  _addEvent(EventType type){
    Event e = Event(type);
    _events.add(e);
  }

  _removeEvent(EventType type){
    Event? event = _events.firstWhereOrNull((e) => e.type == type);
    if(event != null){
      _events.remove(event);
      event.dispose();
      event = null;
    }
  }

  launchEvent(EventType type, {Map<String,dynamic>? data}){
    Event event = _events.firstWhere((e) => e.type == type);
    debugPrint('EventManager launch event ${event.type.toString()} with data ${data.toString()}');
    event.launch(data);
  }

  StreamSubscription subscribeEvent(EventType type, Function onEvent){
    Event event = _events.firstWhere((e) => e.type == type);
    return event.subscribe(onEvent);
  }

  void unsubscribeEvent(StreamSubscription subscription){
    Event event = _events.firstWhere((e) => e.haveSubscription(subscription) == true);
    event.unsubscribe(subscription);
  }

  void printInfo(){
    debugPrint('EventManager info');
    for(int idxEvent = 0; idxEvent < _events.length; idxEvent++){
      String eventInfo = _events[idxEvent].info();
      debugPrint(' -> $eventInfo');
    }
  }
}