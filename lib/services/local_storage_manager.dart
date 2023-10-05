import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager{
  bool _initialized = false;
  late SharedPreferences storage;

  // Singleton
  static final LocalStorageManager _instance = LocalStorageManager._internal();

  factory LocalStorageManager(){
    return _instance;
  }

  LocalStorageManager._internal();

  Future<void> init({bool clear = false}) async {
    storage = await SharedPreferences.getInstance();
    _initialized = true;
    if(clear){
      clearLocalStorage();
    }
  }

  void clearLocalStorage(){
    if(_initialized){
      storage.clear();
    }
  }
}