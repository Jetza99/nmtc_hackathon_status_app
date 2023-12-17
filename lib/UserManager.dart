import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserManager {

FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signInWithEmailAndPassword(String email, String password) async{
  try{
    UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }on FirebaseAuthException catch (e){
    if(e.code == 'invalid-credential'){
      print('Invalid email or password.');
      Fluttertoast.showToast(
          msg: "Invalid email or password.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      print('An error occurred: ${e.code}');
      Fluttertoast.showToast(
          msg: 'An error occurred: ${e.code}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}


}