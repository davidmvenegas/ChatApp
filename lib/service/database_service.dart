import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  DatabaseService({this.uid});
  final String? uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // ------------------ USER ------------------
  Future getUser(String email) async {
    return await userCollection.where('email', isEqualTo: email).get();
  }

  Future getUserData() async {
    return userCollection.doc(uid).snapshots();
  }

  Future updateUser(String username, String email) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'email': email,
      'groups': [],
      'uid': uid,
    });
  }

  // ------------------ GROUP ------------------
  Future getGroup(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot groupDocumentSnapshot = await groupDocumentReference.get();
    return groupDocumentSnapshot['groupAdmin'];
  }

  Future createGroup(String groupName, String userId, String userName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'groupId': '',
      'groupName': groupName,
      'groupAdmin': "${userId}_$userName",
      'members': [],
      'recentMessage': '',
      'recentMessageTime': '',
      'recentMessageSender': '',
    });

    await groupDocumentReference.update({
      "groupId": groupDocumentReference.id,
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // ------------------ CHAT ------------------
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future sendMessage(String groupId, String message, String user) async {
    return await groupCollection.doc(groupId).collection('messages').add({
      'message': message,
      'sender': "${uid}_$user",
      'time': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
