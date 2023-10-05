import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseUtils{
  static Future<String?> uploadFileFirebaseStorage(String path, XFile file, {Function? onProgress}) async{ 
    try{
      Reference fileRef = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = fileRef.putData(await file.readAsBytes());
      StreamSubscription<TaskSnapshot> streamSubscriptionUploadTask = uploadTask.snapshotEvents.listen((event) {
        double progressPercent = (event.bytesTransferred / event.totalBytes) * 100;
        debugPrint('Upload state ${event.state}, progress ${progressPercent.toString()}% (${event.bytesTransferred.toString()}/${event.totalBytes.toString()})');
        if(onProgress != null){
          onProgress(progressPercent);
        }
      }, onError: (e) {
        debugPrint('Error when upload file to FirebaseStorage: ${e.toString()}');
      });

      await uploadTask.whenComplete(() {
        debugPrint('Upload task completed.');
      });
      streamSubscriptionUploadTask.cancel();

      String fileDownloadUrl = await fileRef.getDownloadURL();
      debugPrint('Download Url: $fileDownloadUrl');
      return fileDownloadUrl;
    } catch(e){
      debugPrint('Exception when upload file to FirebaseStorage: ${e.toString()}');
      return null;
    }
  }
}