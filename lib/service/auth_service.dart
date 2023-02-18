import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // REGISTER
  Future register(username, email, password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await DatabaseService(uid: userCredential.user?.uid)
          .updateUserData(username, email);
      await HelperFunctions.saveUserLoggedInStatus(true);
      await HelperFunctions.saveUserName(username);
      await HelperFunctions.saveUserEmail(email);
      return true;
    } catch (e) {
      return e;
    }
  }

  // LOGIN
  Future signIn(email, password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      QuerySnapshot snapshot =
          await DatabaseService(uid: userCredential.user?.uid)
              .getUserData(email);
      await HelperFunctions.saveUserLoggedInStatus(true);
      await HelperFunctions.saveUserName(snapshot.docs[0]['username']);
      await HelperFunctions.saveUserEmail(email);
      return true;
    } catch (e) {
      return e;
    }
  }

  // LOGOUT
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserName('');
      await HelperFunctions.saveUserEmail('');
      await firebaseAuth.signOut();
    } catch (e) {
      return e;
    }
  }
}
