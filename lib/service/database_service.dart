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

  Future updateUser(String username, String email) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'email': email,
      'groups': [],
      'uid': uid,
    });
  }

  // ------------------ GROUPS ------------------
  Future getGroup(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future getAllGroups() async {
    return groupCollection.orderBy('createdAt', descending: true).get();
  }

  Future getUsersGroups(String userId, String userName) async {
    return groupCollection
        .where('members', arrayContains: "${userId}_$userName")
        .orderBy('recentMessageTime', descending: true)
        .snapshots();
  }

  Future searchGroups(String keyword) async {
    return groupCollection
        .where('groupName', isGreaterThanOrEqualTo: keyword)
        .where('groupName', isLessThanOrEqualTo: "$keyword\uf8ff")
        .get();
  }

  Future createGroup(String groupName, String userId, String userName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'groupId': '',
      'groupName': groupName,
      'groupAdmin': "${userId}_$userName",
      'createdAt': DateTime.now().millisecondsSinceEpoch,
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

  Future joinGroup(
      String groupId, String groupName, String userId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(userId);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${userId}_$userName"])
    });
  }

  Future leaveGroup(
      String groupId, String groupName, String userId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(userId);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    await userDocumentReference.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayRemove(["${userId}_$userName"])
    });
  }

  Future deleteGroup(String groupId) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot groupSnapshot = await groupDocumentReference.get();
    List members = groupSnapshot.get('members');

    for (var member in members) {
      String userId = member.split('_')[0];
      DocumentReference userDocumentReference = userCollection.doc(userId);
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(
            ["${groupId}_${groupSnapshot.get('groupName')}"])
      });
    }

    return await groupDocumentReference.delete();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference ref = groupCollection.doc(groupId);
    DocumentSnapshot snapshot = await ref.get();
    return snapshot.get('groupAdmin');
  }

  Future getGroupCreatedAt(String groupId) async {
    DocumentReference ref = groupCollection.doc(groupId);
    DocumentSnapshot snapshot = await ref.get();
    return snapshot.get('createdAt');
  }

  // ------------------ CHAT ------------------
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future sendMessage(
      String groupId, String message, String userId, String userName) async {
    await groupCollection.doc(groupId).collection('messages').add({
      'message': message,
      'sender': "${userId}_$userName",
      'time': DateTime.now().millisecondsSinceEpoch,
    });
    await groupCollection.doc(groupId).update({
      'recentMessage': message,
      'recentMessageTime': DateTime.now().millisecondsSinceEpoch,
      'recentMessageSender': "${userId}_$userName",
    });
  }
}
