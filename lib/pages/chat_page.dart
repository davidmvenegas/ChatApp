import 'dart:async';
import 'package:chat_app/pages/info_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  Stream<QuerySnapshot>? chatMessages;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String groupAdmin = '';
  int? groupCreatedAt;
  final TextEditingController messageEditingController =
      TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    handleGetChats();
    fetchInfoData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    messageEditingController.dispose();
    super.dispose();
  }

  void fetchInfoData() async {
    await DatabaseService()
        .getGroupAdmin(widget.groupId)
        .then((res) => setState(() => groupAdmin = res));
    await DatabaseService()
        .getGroupCreatedAt(widget.groupId)
        .then((res) => setState(() => groupCreatedAt = res));
  }

  void handleGetChats() async {
    DatabaseService()
        .getChats(widget.groupId)
        .then((res) => setState(() => chatMessages = res));
  }

  void sendMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      DatabaseService()
          .sendMessage(widget.groupId, messageEditingController.text,
              currentUserId, widget.username)
          .whenComplete(() => handleGetChats());
      messageEditingController.clear();
    }
  }

  String formatMessageDate(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat dayFormat = DateFormat('dd/MM/yy');
    final DateFormat hourFormat = DateFormat('h:mm a');
    if (dateTime.day > DateTime.now().day - 1) {
      return hourFormat.format(dateTime);
    } else {
      return dayFormat.format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.groupName,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
          actions: [
            IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    InfoPage(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        groupAdmin: groupAdmin,
                        groupCreatedAt: groupCreatedAt));
              },
              padding: const EdgeInsets.only(right: 4, top: 2),
              icon: const Icon(Icons.info_outline, size: 26),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(bottom: 110),
              child: StreamBuilder<QuerySnapshot>(
                stream: chatMessages,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 120),
                      child: const Center(
                          child: Text('Send the first message!',
                              style: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500))),
                    );
                  }
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot currentDoc =
                            snapshot.data!.docs[index];
                        String message = currentDoc['message'];
                        String sender = currentDoc['sender'].split('_')[1];
                        int recentMessageTime = currentDoc['time'];

                        bool sentByMe = '${currentUserId}_${widget.username}' ==
                            currentDoc['sender'];
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent));
                        return Container(
                          padding: EdgeInsets.only(
                              top: 18,
                              bottom: 0,
                              left: sentByMe ? 0 : 24,
                              right: sentByMe ? 24 : 0),
                          alignment: sentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: sentByMe
                                ? const EdgeInsets.only(left: 30)
                                : const EdgeInsets.only(right: 30),
                            padding: const EdgeInsets.only(
                                top: 12, bottom: 12, left: 18.5, right: 18.5),
                            decoration: BoxDecoration(
                              borderRadius: sentByMe
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomLeft: Radius.circular(23))
                                  : const BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomRight: Radius.circular(23)),
                              color: sentByMe
                                  ? const Color(0xff007EF4)
                                  : const Color.fromARGB(225, 31, 31, 31),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                  minWidth: MediaQuery.of(context).size.width *
                                      0.375),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: sentByMe ? null : 0,
                                    child: Text(sentByMe ? 'You' : sender,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: sentByMe
                                                ? Colors.white
                                                : Colors.white,
                                            fontSize: 17.5,
                                            fontFamily: 'OverpassRegular',
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 25.5, bottom: 21.5),
                                    child: Text(message,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: sentByMe
                                                ? Colors.white
                                                : Colors.white,
                                            fontSize: 16.5,
                                            fontFamily: 'OverpassRegular',
                                            fontWeight: FontWeight.w300)),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: sentByMe ? 0 : null,
                                    left: sentByMe ? null : 0,
                                    child: Text(
                                        formatMessageDate(recentMessageTime),
                                        style: TextStyle(
                                            color: sentByMe
                                                ? Colors.white
                                                : Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'OverpassRegular',
                                            fontWeight: FontWeight.w300)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: const Color.fromARGB(165, 0, 0, 0),
                height: 110,
                padding: const EdgeInsets.only(left: 36, right: 15, bottom: 25),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.5,
                          fontFamily: 'OverpassRegular',
                          fontWeight: FontWeight.w400),
                      decoration: const InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(
                            color: Colors.white60,
                            fontSize: 19.25,
                          ),
                          border: InputBorder.none),
                    )),
                    TextButton(
                      onPressed: () => sendMessage(),
                      style: TextButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white, size: 22),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
