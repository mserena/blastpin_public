import 'dart:convert';
import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/objects/content/content.dart';
import 'package:blastpin/objects/content/content_event.dart';
import 'package:blastpin/objects/content/content_place.dart';
import 'package:blastpin/objects/map/blastpin_location.dart';
import 'package:blastpin/services/cloud_functions_manager.dart';
import 'package:blastpin/services/local_storage_manager.dart';
import 'package:blastpin/services/notification_manager.dart';
import 'package:blastpin/services/user_manager.dart';
import 'package:blastpin/utils/firebase_utils.dart';
import 'package:blastpin/utils/text_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class EditContentManager{
  Content? _editContent;
  EditContentStep _currentStep = EditContentStep.type;

  // Singleton
  static final EditContentManager _instance = EditContentManager._internal();

  factory EditContentManager(){
    return _instance;
  }

  EditContentManager._internal();

  init() async{
    await restoreEditContentLocal();
  }

  Future<bool> createEditContent(ContentBlastPinType type) async{
    String? userId = UserManager().getUserId();
    if(userId != null){
      switch(type) {
        case ContentBlastPinType.event:
          _editContent = ContentEvent(userId);
          break;
        case ContentBlastPinType.place:
          _editContent = ContentPlace(userId);
          break;
      }
      await storeEditContentDataLocal();
      return true;
    }
    return false;
  }

  Content? getEditContent(){
    return _editContent;
  }

  EditContentStep getCurrentStep(){
    return _currentStep;
  }

  void setCurrentStep(EditContentStep step, {bool force = false}) async{
    if(step.index > _currentStep.index || force){
      _currentStep = step;
      await LocalStorageManager().storage.setString(defLocalStorageEditContentCurrentStep,_currentStep.toString());
    }
  }

  Future<void> cleanEditContent() async{
    if(_editContent != null){
      _editContent!.dispose();
    }
    _editContent = null;
    _currentStep = EditContentStep.type;
    await LocalStorageManager().storage.remove(defLocalStorageEditContentCurrentStep);
    await LocalStorageManager().storage.remove(defLocalStorageEditContentData);
    await LocalStorageManager().storage.remove(defLocalStorageEditContentMedia);
  }

  Future<void> restoreEditContentLocal() async {
    try{
      String? editContentCurrentStepStr = LocalStorageManager().storage.getString(defLocalStorageEditContentCurrentStep);
      if(editContentCurrentStepStr != null){
        EditContentStep? editContentCurrentStep = TextUtils.enumFromString(EditContentStep.values, editContentCurrentStepStr);
        if(editContentCurrentStep != null){
          _currentStep = editContentCurrentStep;
        }
      }

      String? editContentDataStorage = LocalStorageManager().storage.getString(defLocalStorageEditContentData);
      if(editContentDataStorage != null){
        _editContent = Content.fromJson(jsonDecode(editContentDataStorage));
      }

      String? editContentMediaStorage = LocalStorageManager().storage.getString(defLocalStorageEditContentMedia);
      if(editContentMediaStorage != null){
        if(_editContent != null){
          Map<String,dynamic> mediaData = jsonDecode(editContentMediaStorage);
          mediaData.forEach((name, mediaEncoded) {
            Uint8List imageBytes = base64Decode(mediaEncoded);
            XFile mediaFile = XFile.fromData(
              imageBytes,
              name: name,
            );
            _editContent!.media.add(mediaFile); 
          });
        } else {
          cleanEditContent();
        }
      }

    }catch(e){
      //TODO: restore this
      //await cleanEditContent();
      debugPrint('Error on editContent restore from local storage: ${e.toString()}');
    }
  }

  Future<void> storeCompleteEditContentLocal() async{
    await storeEditContentDataLocal();
    await storeEditContentMediaLocal();
  }

  Future<void> storeEditContentDataLocal() async{
    if(_editContent != null){
      try{
        String contentJson = jsonEncode(_editContent!.toJson());
        await LocalStorageManager().storage.setString(defLocalStorageEditContentData,contentJson);
      }catch(e){
        debugPrint('Error on local store editContent: ${e.toString()}');
      }
    }
  }

  Future<void> storeEditContentMediaLocal() async{
    if(_editContent != null){
      try{
        String contentJson = await _encodeEditContentMedia();
        await LocalStorageManager().storage.setString(defLocalStorageEditContentMedia,contentJson);
      }catch(e){
        debugPrint('Error on local store editContent: ${e.toString()}');
      }
    }
  }

  Future<String> _encodeEditContentMedia() async{
    String mediaJson = '';
    if(_editContent != null && _editContent!.media.isNotEmpty){
      Map<String,String> allMediaEncoded = <String,String>{};
      for(int idxMedia = 0; idxMedia < _editContent!.media.length; idxMedia++){
        XFile image = _editContent!.media[idxMedia];
        Uint8List imageBytes = await image.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        allMediaEncoded.putIfAbsent(image.name,() => base64Image);
      }
      mediaJson = jsonEncode(allMediaEncoded);
    }
    return mediaJson;
  }

  void addMediaToContent(int idx, XFile file) async{
    if(_editContent != null){
      if(_editContent!.media.contains(file)){
        //media swap
        int currentMediaIdx = _editContent!.media.indexOf(file);
        XFile? targetMediaFile = idx < _editContent!.media.length ? _editContent!.media[idx] : null;
        if(targetMediaFile != null){
          _editContent!.media[currentMediaIdx] = targetMediaFile;
          _editContent!.media[idx] = file;
        }
      } else {
        _editContent!.media.add(file);
      }
      storeEditContentMediaLocal();
    }
  }

  Future<bool> addLanguage(String isoCode, Map<String,String> language, {bool store = true}) async{
    bool changes = false;
    if(_editContent != null){
      if(_editContent!.languages.containsKey(isoCode)){
        Map<String,String> contentLanguage = _editContent!.languages[isoCode]!;
        if(language.containsKey(defContentLanguageTitleKey) && contentLanguage.containsKey(defContentLanguageTitleKey) && contentLanguage[defContentLanguageTitleKey] != language[defContentLanguageTitleKey]){
          changes = true;
        }
        if(language.containsKey(defContentLanguageDescriptionKey) && contentLanguage.containsKey(defContentLanguageDescriptionKey) && contentLanguage[defContentLanguageDescriptionKey] != language[defContentLanguageDescriptionKey]){
          changes = true;
        }
        if(changes){
          _editContent!.languages[isoCode] = language;
        }
      } else {
        _editContent!.languages.putIfAbsent(isoCode, () => language);
        changes = true;
      }
      if(changes && store){
        await storeEditContentDataLocal();
      }
    }
    return changes;
  }

  Future<void> setEventRepeat(EventRepeat repeat, {dynamic repeatData}) async{
    if(_editContent != null && _editContent!.type == ContentBlastPinType.event){
      ContentEvent contentEvent = (_editContent as ContentEvent);
      contentEvent.repeat = repeat;
      contentEvent.repeatWeekDays = null;
      switch(repeat){
        case EventRepeat.unique:
        case EventRepeat.daily:
        case EventRepeat.monthly:
        case EventRepeat.annually:
          break;
        case EventRepeat.weekly:
          List<String> repeatWeekdaysShortStr = repeatData as List<String>;
          List<int> repeatWeekDaysIds = [];
          for(int idxDay = 0; idxDay < repeatWeekdaysShortStr.length; idxDay++){
            repeatWeekDaysIds.add(defWeekdaysShort.indexOf(repeatWeekdaysShortStr[idxDay]));
          }
          if(repeatWeekDaysIds.isNotEmpty){
            repeatWeekDaysIds.sort();
            contentEvent.repeatWeekDays = repeatWeekDaysIds;
          } else {
            contentEvent.repeat = EventRepeat.unique;
          }
          break;
      }
      await storeEditContentDataLocal();
    }
  }

  Future<void> setLocation(BlastPinLocation? location) async{
    if(_editContent != null){
      _editContent!.location = location;
      await storeEditContentDataLocal();
    }
  }

  Future<void> cancelPublish({bool showErrorNotification = false}) async{
    if(_editContent != null){
      if(_editContent!.id != null){
        await CloudFunctionsManager().deleteContent(contentId: _editContent!.id!, userId: _editContent!.userId);
      }
      _editContent!.status = ContentBlastPinStatus.creating;
      _editContent!.id = null;
      _editContent!.mediaUrls.clear();
      await storeEditContentDataLocal();
      if(showErrorNotification){
        try{
          NotificationManager().addNotification(CustomNotificationType.publishError);
        }catch(e){
          debugPrint('CancelPublish, exception on show notification: ${e.toString()}');
        }
      }
    }
  }

  Future<bool> publish() async{
    try{
      if(_editContent != null){
        if(_editContent!.id != null){
          await cancelPublish();
        }

        //1. Upload content data
        Map<String,dynamic> contentInfo = _editContent!.toJson();
        dynamic response = await CloudFunctionsManager().uploadContentInfo(json: contentInfo);
        bool canContinue = response != null && response.data != null;
        canContinue = canContinue && response.data['result'] == 'done';
        canContinue = canContinue && response.data['id'] != null;
        canContinue = canContinue && response.data['status'] != null;
        if(canContinue){
          String contentId = response.data['id'];
          ContentBlastPinStatus contentStatus = TextUtils.enumFromString(ContentBlastPinStatus.values, response.data['status'])!;
          debugPrint('Created content with id $contentId and status ${contentStatus.toString()}');
          _editContent!.id = contentId;
          _editContent!.status = contentStatus;
          await storeEditContentDataLocal();
        } else {
          await cancelPublish(showErrorNotification: true);
          return false;
        }

        //2. Upload media data
        for(int idxMedia = 0; idxMedia < _editContent!.media.length; idxMedia++){
          XFile media = _editContent!.media[idxMedia];
          String fileExtension = path.extension(media.name);
          String uploadPath = '$defContentBucketPath${_editContent!.id!}/${idxMedia.toString()}$fileExtension';
          debugPrint('Uploading content file to $uploadPath');
          String? downloadUrl = await FirebaseUtils.uploadFileFirebaseStorage(uploadPath, media);
          if(downloadUrl == null){
            await cancelPublish(showErrorNotification: true);
            return false;
          } else {
            _editContent!.mediaUrls.add(downloadUrl);
          }
        }

        //3. Update Content with media links
        response = await CloudFunctionsManager().uploadContentMedia(
          contentId: _editContent!.id!,
          userId: _editContent!.userId,
          mediaUrls: jsonEncode(_editContent!.mediaUrls)
        );
        canContinue = response != null && response.data != null;
        canContinue = canContinue && response.data['result'] == 'done';
        canContinue = canContinue && response.data['status'] != null;
        if(canContinue){
          ContentBlastPinStatus contentStatus = TextUtils.enumFromString(ContentBlastPinStatus.values, response.data['status'])!;
          debugPrint('Media data uploaded on content, status ${contentStatus.toString()}');
          _editContent!.status = contentStatus;
          await storeEditContentDataLocal();
        } else {
          await cancelPublish(showErrorNotification: true);
          return false;
        }
      }
    } catch(e){
      debugPrint('Error on publish editContent: ${e.toString()}');
      await cancelPublish(showErrorNotification: true);
      return false;
    }
    NotificationManager().addNotification(CustomNotificationType.publishDone);
    debugPrint('Content published.');
    return true;
  }
}