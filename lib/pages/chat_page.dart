import 'package:chat_app/pages/info_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String username;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.username})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  String groupAdmin = '';

  @override
  void initState() {
    super.initState();
    getGroupChatData();
  }

  void getGroupChatData() async {
    DatabaseService()
        .getChats(widget.groupId)
        .then((res) => setState(() => chats = res));
    DatabaseService()
        .getGroupAdmin(widget.groupId)
        .then((res) => setState(() => groupAdmin = res));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                  context,
                  InfoPage(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      groupAdmin: groupAdmin));
            },
            padding: const EdgeInsets.only(right: 4, top: 2),
            icon: const Icon(Icons.info_outline, size: 26),
          ),
        ],
      ),
      body: Center(child: Text(widget.groupName)),
    );
  }
}
