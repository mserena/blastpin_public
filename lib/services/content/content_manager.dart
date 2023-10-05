class ContentManager{
  // Singleton
  static final ContentManager _instance = ContentManager._internal();

  factory ContentManager(){
    return _instance;
  }

  ContentManager._internal();

  init(){
  }
}