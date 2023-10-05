import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/events/events_manager.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlastPinUser{
  User firebaseUser;

  BlastPinUser({required this.firebaseUser});
}

class UserManager{
  BlastPinUser? _currentUser;

  // Singleton
  static final UserManager _instance = UserManager._internal();

  factory UserManager(){
    return _instance;
  }

  UserManager._internal();

  bool isSignedIn(){
    if (_currentUser != null){
      return true;
    }
    return false;
  }

  void createUser(User firebaseUser){
    signOut();
    _currentUser = BlastPinUser(firebaseUser: firebaseUser);
    //TODO: get extra user cloud data
    EventsManager().launchEvent(EventType.eUserSignInEvent);
  }

  void signOut(){
    if(_currentUser != null){
      _currentUser = null;
      EventsManager().launchEvent(EventType.eUserSignOutEvent);
    }
  }

  String? getUsername(){
    String? username;
    if(isSignedIn()){
      username = _currentUser!.firebaseUser.displayName;
      if(username != null){
        username = username.split(' ').first;
        return username.toCapitalized();
      }
    }
    return username;
  }

  String? getUserId(){
    String? userId;
    if(isSignedIn()){
      userId = _currentUser!.firebaseUser.uid;
    }
    return userId;
  }
}