import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/alerts.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAdmin;
  final int? groupCreatedAt;

  const InfoPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.groupAdmin,
      required this.groupCreatedAt})
      : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Stream? currentGroup;
  String currentUsername = '';
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchInitialData() async {
    await HelperFunctions.getUserUsername()
        .then((value) => setState(() => currentUsername = value!));
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroup(widget.groupId)
        .then((res) => setState(() => currentGroup = res));
  }

  void handleLeaveGroup() async {
    nextScreenReplace(context, const HomePage());
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .leaveGroup(
            widget.groupId, widget.groupName, currentUser!.uid, currentUsername)
        .whenComplete(() => {
              showRichTextSnackBar(
                  context, Colors.red, 'You left ', widget.groupName, '')
            });
  }

  void handleDeleteGroup() async {
    nextScreenReplace(context, const HomePage());
    await DatabaseService()
        .deleteGroup(widget.groupId)
        .then((value) => showRichTextSnackBar(
            context, Colors.red, 'You deleted ', widget.groupName, ''))
        .onError((error, _) =>
            showSnackBar(context, Colors.red, error.toString().split('] ')[1]));
  }

  String extractId(String res) => res.substring(0, res.indexOf("_"));
  String extractName(String res) => res.substring(res.indexOf("_") + 1);
  bool isAdmin() => extractId(widget.groupAdmin) == currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Group Info',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.groupName,
                      style: const TextStyle(
                          color: Color.fromARGB(215, 0, 0, 0),
                          fontWeight: FontWeight.w700,
                          fontSize: 30.75)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(148, 159, 204, 255),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(20, 0, 0, 0),
                              offset: Offset(6, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Admin:  ',
                                style: const TextStyle(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: extractName(widget.groupAdmin),
                                      style: const TextStyle(
                                          color: Color.fromARGB(200, 0, 0, 0),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16))
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                text: 'Created:  ',
                                style: const TextStyle(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: widget.groupCreatedAt != null
                                          ? DateFormat.yMMMMd().format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  widget.groupCreatedAt!))
                                          : '',
                                      style: const TextStyle(
                                          color: Color.fromARGB(200, 0, 0, 0),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16))
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                text: 'Group ID:  ',
                                style: const TextStyle(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: widget.groupId,
                                      style: const TextStyle(
                                          color: Color.fromARGB(200, 0, 0, 0),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromARGB(20, 0, 0, 0),
                    thickness: 1.5,
                    height: 30,
                  ),
                  const SizedBox(height: 4),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Members:',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                                color: Colors.black87)),
                        const SizedBox(height: 10),
                        StreamBuilder(
                          stream: currentGroup,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return SingleChildScrollView(
                                child: ListView.builder(
                                  itemCount: snapshot.data['members'].length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    String memberName = extractName(
                                        snapshot.data['members'][index]);
                                    var cleanedMemberName = memberName ==
                                            extractName(widget.groupAdmin)
                                        ? RichText(
                                            text: TextSpan(
                                              text: memberName,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 19),
                                              children: const [
                                                TextSpan(
                                                    text: '  (ADMIN)',
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15.5))
                                              ],
                                            ),
                                          )
                                        : Text(memberName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20));
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.5, vertical: 5),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blue,
                                          child: Text(
                                            memberName[0].toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        title: cleanedMemberName,
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return const Center(
                                  heightFactor: 10,
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
                            }
                          },
                        ),
                      ])
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: isAdmin()
                    ? Center(
                        child: TextButton(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('Delete Group',
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w600)),
                                    content: const Text(
                                        'Are you sure you want to delete this group?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            fixedSize: const Size(76, 32),
                                          ),
                                          child: const Text('CANCEL',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      TextButton(
                                          onPressed: () => handleDeleteGroup(),
                                          style: TextButton.styleFrom(
                                            fixedSize: const Size(76, 32),
                                            backgroundColor: Colors.blue,
                                          ),
                                          child: const Text('OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)))
                                    ],
                                  )),
                          child: const Text('DELETE GROUP',
                              style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      )
                    : Center(
                        child: TextButton(
                          onPressed: () => handleLeaveGroup(),
                          child: const Text('LEAVE GROUP',
                              style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ),
              )
            ]),
      ),
    );
  }
}
