import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class CloudFunctionsManager{
  // Singleton
  static final CloudFunctionsManager _instance = CloudFunctionsManager._internal();

  factory CloudFunctionsManager(){
    return _instance;
  }

  CloudFunctionsManager._internal();

  void _processResponse(dynamic response){
    if(response != null){
      try{
        if(response.data['date'] != null){
          debugPrint('Server time: ${response.data['date'].toString()}');
        }
      }catch(e){
        debugPrint('error on _processResponse: ${e.toString()}');
      }
    }
  }

  Future<dynamic> getServerTime() async{
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupUtils-getServerTime',
      );
      
      dynamic response = await callable.call();
      _processResponse(response);
      return response;  
    }catch(e){
      debugPrint('error on getServerTime: ${e.toString()}');
      return null;
    }
  }

  /*
  *
  * User functions
  *
  */
  Future<dynamic> getUserAuthToken({required String email, String? name = ''}) async{
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupUser-getUserAuthToken',
      );
      
      Map<String,dynamic> inputData = <String,dynamic>{};
      inputData.putIfAbsent('email', () => email);
      inputData.putIfAbsent('name', () => name);

      dynamic response = await callable.call(inputData);
      _processResponse(response);
      return response;
    } catch (e) {
      debugPrint('error on cloud function getUserAuthToken: ${e.toString()}');
      return null;
    }
  }

  /*
  *
  * Tags functions
  *
  */
  Future<dynamic> getTags() async{
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupTags-getTags',
      );

      dynamic response = await callable.call();
      _processResponse(response);
      return response;
    } catch (e) {
      debugPrint('error on cloud function getTags: ${e.toString()}');
      return null;
    }
  }

  /*
  *
  * Utils functions
  *
  */
  Future<dynamic> checkUrl({required String url}) async{
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupUtils-checkUrl',
      );
      
      Map<String,dynamic> inputData = <String,dynamic>{};
      inputData.putIfAbsent('url', () => url);

      dynamic response = await callable.call(inputData);
      _processResponse(response);
      return response;
    } catch (e) {
      debugPrint('error on cloud function checkUrl: ${e.toString()}');
      return null;
    }
  }

  /*
  *
  * Content functions
  *
  */
  Future<dynamic> uploadContentInfo({required Map<String,dynamic> json}) async {
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupContent-uploadContentInfo',
      );
      
      dynamic response = await callable.call(json);

      _processResponse(response);
      return response;  
    }catch(e){
      debugPrint('error on cloud function uploadContentInfo: ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> uploadContentMedia({required String contentId, required String userId, required String mediaUrls}) async {
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupContent-uploadContentMedia',
      );
      
      Map<String,dynamic> inputData = <String,dynamic>{};
      inputData.putIfAbsent('contentId', () => contentId);
      inputData.putIfAbsent('userId', () => userId);
      inputData.putIfAbsent('mediaUrls', () => mediaUrls);

      dynamic response = await callable.call(inputData);

      _processResponse(response);
      return response;  
    }catch(e){
      debugPrint('error on cloud function uploadContentMedia: ${e.toString()}');
      return null;
    }
  }

  Future<dynamic> deleteContent({required String contentId, required String userId}) async {
    try{
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'groupContent-deleteContent',
      );
      
      Map<String,dynamic> inputData = <String,dynamic>{};
      inputData.putIfAbsent('contentId', () => contentId);
      inputData.putIfAbsent('userId', () => userId);

      dynamic response = await callable.call(inputData);

      _processResponse(response);
      return response;  
    }catch(e){
      debugPrint('error on cloud function deleteContent: ${e.toString()}');
      return null;
    }
  }
}