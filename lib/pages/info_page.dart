import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/alerts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAdmin;

  const InfoPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.groupAdmin})
      : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Stream? currentGroup;
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    getInfoData();
    getCurrentUsername();
  }

  void getCurrentUsername() async {
    await HelperFunctions.getUserUsername()
        .then((value) => setState(() => currentUsername = value!));
  }

  void getInfoData() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroup(widget.groupId)
        .then((res) => setState(() => currentGroup = res));
  }

  void handleLeaveGroup() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false);
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .leaveGroup(
            widget.groupId, widget.groupName, currentUser!.uid, currentUsername)
        .whenComplete(() => {
              showRichTextSnackBar(
                  context, Colors.red, 'You left ', widget.groupName, '')
            });
  }

  String extractId(String res) => res.substring(0, res.indexOf("_"));
  String extractName(String res) => res.substring(res.indexOf("_") + 1);

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
                  const SizedBox(height: 2.5),
                  Text(widget.groupName,
                      style: const TextStyle(
                          color: Color.fromARGB(215, 0, 0, 0),
                          fontWeight: FontWeight.w700,
                          fontSize: 28.5)),
                  const SizedBox(height: 6.5),
                  const Text(
                    'Created Feburary 20, 2022',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.5,
                        color: Color.fromARGB(140, 0, 0, 0)),
                  ),
                  const SizedBox(height: 14),
                  const Divider(
                    color: Color.fromARGB(60, 0, 0, 0),
                    thickness: 1,
                    height: 32.5,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MEMBERS:',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color.fromARGB(201, 0, 0, 0))),
                        const SizedBox(height: 8),
                        StreamBuilder(
                          stream: currentGroup,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: snapshot.data['members'].length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  String memberId = extractId(
                                      snapshot.data['members'][index]);
                                  String memberName = extractName(
                                      snapshot.data['members'][index]);
                                  var cleanedMemberName = memberName ==
                                          extractName(widget.groupAdmin)
                                      ? RichText(
                                          text: TextSpan(
                                            text: memberName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 19),
                                            children: const [
                                              TextSpan(
                                                  text: ' (ADMIN)',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16))
                                            ],
                                          ),
                                        )
                                      : Text(memberName,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 19));
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 6),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          memberName[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      title: cleanedMemberName,
                                      subtitle: Text(memberId),
                                    ),
                                  );
                                },
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
                child: Center(
                  child: TextButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text('Leave Group',
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600)),
                              content:
                                  const Text('Are you sure you want to leave?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      fixedSize: const Size(76, 32),
                                    ),
                                    child: const Text('CANCEL',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700))),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      handleLeaveGroup();
                                    },
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
