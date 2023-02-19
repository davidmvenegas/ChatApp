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
  Future getUsersGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // CREATE GROUP
  // Future createGroup(String id, String name, String username) async {
  //   DocumentReference groupDocumentReference = await groupCollection.add({
  //     'id': '',
  //     'name': name,
  //     'admin': "${id}_$username",
  //     'members': [],
  //     'recentMessage': '',
  //     'recentMessageTime': '',
  //     'recentMessageSender': '',
  //   });
  //   await groupDocumentReference.update({
  //     'id': groupDocumentReference.id,
  //     'members': [
  //       FieldValue.arrayUnion(["${uid}_$username"])
  //     ]
  //   });
  //   await userCollection.doc(uid).update({
  //     'groups': FieldValue.arrayUnion(["${groupDocumentReference.id}_$name"])
  //   });
  // }

  Future createGroup(String id, String name, String username) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'id': '',
      'name': name,
      'admin': "${id}_$username",
      'members': [],
      'recentMessage': '',
      'recentMessageTime': '',
      'recentMessageSender': '',
    });

    await groupDocumentReference.update({
      "id": groupDocumentReference.id,
      "members": FieldValue.arrayUnion(["${uid}_$username"]),
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${groupDocumentReference.id}_$name"])
    });
  }
}
