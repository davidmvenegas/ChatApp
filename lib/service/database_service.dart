import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  DatabaseService({this.uid});
  final String? uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // GET USER
  Future getUser(String email) async {
    return await userCollection.where('email', isEqualTo: email).get();
  }

  // UPDATE USER
  Future updateUser(String username, String email) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'email': email,
      'groups': [],
      'uid': uid,
    });
  }

  // GET GROUPS
  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }
}
