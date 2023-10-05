import 'package:blastpin/services/cloud_functions_manager.dart';
import 'package:blastpin/utils/datetime_utils.dart';
import 'package:flutter/material.dart';

class TagsManager{
  bool _loading = false;
  List<String> tags = [];

  // Singleton
  static final TagsManager _instance = TagsManager._internal();

  factory TagsManager(){
    return _instance;
  }

  TagsManager._internal();

  init() async{
    await getTags(forceUpdate: true);
  }

  Future<List<String>> getTags({bool forceUpdate = false}) async{
    DateTimeUtils.waitWhile(() => !_loading, const Duration(milliseconds: 100));
    if(tags.isEmpty || forceUpdate){
      debugPrint('Getting tags from cloud.');
      tags = await _getTagsFromCloud();
    }
    return tags;
  }

  Future<List<String>> _getTagsFromCloud() async{
    _loading = true;
    List<String> cloudTags = [];
    var response = await CloudFunctionsManager().getTags();
    if(response != null && response.data != null && response.data['tags'] != null){
      List<dynamic> responsecloudTags = response.data['tags'];
      for(int idxTag = 0; idxTag < responsecloudTags.length; idxTag++){
        try{
          String tagId = responsecloudTags[idxTag]['tagId'];
          if(!cloudTags.contains(tagId)){
            cloudTags.add(tagId);
          }
        } catch(e){
          debugPrint('Error on process _getTagsFromCloud ${e.toString()}');
        }
      }
    }
    _loading = false;
    return cloudTags;
  }
}