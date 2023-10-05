import 'package:blastpin/defines/globals.dart';
import 'package:blastpin/services/cloud_functions_manager.dart';
import 'package:blastpin/services/local_storage_manager.dart';
import 'package:blastpin/services/user_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthentificationManager{
  //Authentification provider 
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Singleton
  static final AuthentificationManager _instance = AuthentificationManager._internal();

  factory AuthentificationManager(){
    return _instance;
  }

  AuthentificationManager._internal();

  init() async {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    User? firebaseUser = await getCurrentFirebaseUser();
    if(firebaseUser != null){
      debugPrint('User is signed in!');
      if(firebaseUser.email == null){
        debugPrint('There are missing data on firebase user. Auto sign out.');
        await signOut();
      } else {
        UserManager().createUser(firebaseUser);
      }
    } else {
      debugPrint('There are no user signed in!');
    }
  }

  Future<void> reloadFirebaseUser() async{
    if(FirebaseAuth.instance.currentUser != null){
      await FirebaseAuth.instance.currentUser!.reload();
    }
  }
  
  Future<User?> getCurrentFirebaseUser() async{
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUser ??= await FirebaseAuth.instance.authStateChanges().first;
    return currentUser;
  }

  //Email
  Future<SignInOperationResult> signInWithEmail(String email) async{
    try{
      await signOut();
      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email, 
        actionCodeSettings: ActionCodeSettings(
          url: 'http://localhost:8686/#/signinUsername',
          handleCodeInApp: true
        )
      );
      await LocalStorageManager().storage.setString(defLocalStorageSigninEmail,email);
      return SignInOperationResult.done;
    }catch(e){
      signOut();
      debugPrint('Error on signin with Email: ${e.toString()}');
      return SignInOperationResult.error;
    }
  }

  Future<SignInOperationResult> completeSignInWithEmail(String username) async{
    try{
      String? email = LocalStorageManager().storage.getString(defLocalStorageSigninEmail);
      String? emailLink = gInitialAppUri != null ? gInitialAppUri!.toString() : null;
      if(email != null && emailLink != null && FirebaseAuth.instance.isSignInWithEmailLink(emailLink)){
        debugPrint('Complete signin using email $email with link $emailLink');
        UserCredential credential = await FirebaseAuth.instance.signInWithEmailLink(email: email, emailLink: emailLink);
        if(credential.user != null && !credential.user!.isAnonymous){
          await LocalStorageManager().storage.remove(defLocalStorageSigninEmail);
          await credential.user!.updateDisplayName(username);
          await credential.user!.reload();
          UserManager().createUser(FirebaseAuth.instance.currentUser!);
          return SignInOperationResult.done;
        }
      }
      return SignInOperationResult.error;
    }catch(e){
      signOut();
      debugPrint('Error on signin with Email: ${e.toString()}');
      return SignInOperationResult.error;
    }
  }

  //Google
  Future<SignInOperationResult> signInWithGoogle() async {
    try{
      await signOut();
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if(googleSignInAccount != null){
        SignInOperationResult result = await _completeSignInWithProviders(email: googleSignInAccount.email, name: googleSignInAccount.displayName);
        await _signOutGoogle();
        return result;
      }
      return SignInOperationResult.error;
    }catch(e){
      signOut();
      debugPrint('Error on signin with Google: ${e.toString()}');
      if(e == 'popup_closed'){
        return SignInOperationResult.canceled;
      }
      return SignInOperationResult.error;
    }
  }

  Future<void> _signOutGoogle() async{
    try {
      if(await _googleSignIn.isSignedIn()){
        await _googleSignIn.signOut();
      }
    } catch (error) {
      debugPrint('Error on signout with Google: ${error.toString()}');
    }
  }

  //Facebook
  Future<SignInOperationResult> signInWithFacebook() async {
    try{
      await signOut();
      final result = await FacebookAuth.instance.login();
      if(result.status == LoginStatus.success){
        String email = '';
        String? name;
        final userData = await FacebookAuth.instance.getUserData();
        if(userData['email'] != null){
          email = userData['email'];
        }
        if(userData['name'] != null){
          name = userData['name'];
        }
        await _signOutFacebook();
        return await _completeSignInWithProviders(email: email, name: name);
      }else if(result.status == LoginStatus.cancelled){
        return SignInOperationResult.canceled;
      }else{
        debugPrint('Error on signin with Facebook: ${result.status.toString()}, ${result.message.toString()}');
        return SignInOperationResult.error;
      }
    } catch (e, s) {
      signOut();
      debugPrint('Error on signin with Facebook: ${e.toString()}, ${s.toString()}');
      return SignInOperationResult.error;
    }
  }

  Future _signOutFacebook() async{
    try {
      if(await FacebookAuth.instance.accessToken != null){
        await FacebookAuth.instance.logOut();
      }
    } catch (error) {
      debugPrint('Error on signout with Facebook: ${error.toString()}');
    }
  }

  Future<SignInOperationResult> _completeSignInWithProviders({required String email, String? name}) async {
    User? firebaseUser;
    var response = await CloudFunctionsManager().getUserAuthToken(email: email, name: name);
    if(response != null && response.data != null && response.data['result'] != null && response.data['result'] == 'done'){
      if(response.data['authToken'] != null){
        String authToken = response.data['authToken'];
        UserCredential authResult = await FirebaseAuth.instance.signInWithCustomToken(authToken);
        firebaseUser = authResult.user;
      }
    }

    if(firebaseUser == null || firebaseUser.isAnonymous){
      return SignInOperationResult.error;
    }else{
      UserManager().createUser(firebaseUser);
      return SignInOperationResult.done;
    }
  }

  Future<void> signOut() async{
    await _signOutGoogle();
    await _signOutFacebook();
    await FirebaseAuth.instance.signOut();
    UserManager().signOut();
  }
}