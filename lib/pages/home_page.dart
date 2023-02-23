import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/alerts.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  String username = '';
  String email = '';
  Stream<QuerySnapshot>? usersGroups;
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    handleGetUserData();
  }

  void handleGetUserData() async {
    setState(() => isLoading = true);
    await HelperFunctions.getUserUsername()
        .then((res) => setState(() => username = res!));
    await HelperFunctions.getUserEmail()
        .then((res) => setState(() => email = res!));
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUsersGroups(currentUser!.uid, username)
        .then((res) => setState(() => usersGroups = res));
    setState(() => isLoading = false);
  }

  void alertNewGroupCreated(String groupName) {
    showRichTextSnackBar(
        context, Colors.green, '', groupName, ' successfully created');
  }

  void setLoading(bool val) {
    setState(() => isLoading = val);
  }

  String formatDate(int timestamp) {
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
        title: const Text('ChatApp',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 4, top: 2),
            icon: const Icon(Icons.search, size: 28),
            onPressed: () async {
              nextScreen(context, const SearchPage());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const Icon(Icons.account_circle, size: 140, color: Colors.black54),
            const SizedBox(height: 8),
            Text(username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 20),
            const Divider(
              height: 10,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              onTap: () {},
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading:
                  const Icon(Icons.home_rounded, size: 28, color: Colors.blue),
              title: const Text('Home',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue)),
            ),
            ListTile(
              onTap: () {
                nextScreen(
                    context, ProfilePage(email: email, username: username));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading:
                  const Icon(Icons.person, size: 28, color: Colors.black54),
              title: const Text('Profile',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
            ),
            ListTile(
              onTap: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Logout',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600)),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  fixedSize: const Size(76, 32),
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            TextButton(
                                onPressed: () async {
                                  await authService.signOut().whenComplete(() =>
                                      nextScreenReplace(
                                          context, const LoginPage()));
                                },
                                style: TextButton.styleFrom(
                                  fixedSize: const Size(76, 32),
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('OK',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                          ],
                        ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading:
                  const Icon(Icons.logout, size: 28, color: Colors.black54),
              title: const Text('Logout',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding:
                  EdgeInsets.only(top: 15, bottom: 9.5, left: 20, right: 20),
              child: Text('My Groups',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                  textAlign: TextAlign.left),
            ),
            isLoading
                ? const Center(
                    heightFactor: 10,
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: usersGroups,
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isEmpty) {
                          return Center(
                            heightFactor: 2.75,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, right: 25),
                              child: Column(
                                children: const [
                                  Icon(Icons.group,
                                      size: 87.5, color: Colors.black45),
                                  SizedBox(height: 10),
                                  Text('You are not in any groups yet',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black45)),
                                  SizedBox(height: 10),
                                  Text(
                                      'Click on the + button to create a group or search for groups to join',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black26)),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var currentDoc = snapshot.data!.docs[index];
                              String groupId = currentDoc['groupId'];
                              String groupName = currentDoc['groupName'];
                              String recentMessage =
                                  currentDoc['recentMessage'];
                              String recentMessageSender =
                                  currentDoc['recentMessageSender'];
                              int recentMessageTime =
                                  currentDoc['recentMessageTime'] == ''
                                      ? 0
                                      : currentDoc['recentMessageTime'];
                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        12.0, 8.0, 15.0, 8.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          radius: 30.0,
                                          backgroundColor: Colors.blueGrey[400],
                                          child: Text(
                                            groupName[0].toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(groupName,
                                                style: const TextStyle(
                                                    fontSize: 20.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromARGB(
                                                        185, 0, 0, 0))),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 6.5, top: 0.5),
                                                child: Text(
                                                    recentMessageTime == 0
                                                        ? 'NEW'
                                                        : formatDate(
                                                            recentMessageTime),
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Color.fromARGB(
                                                            165, 0, 0, 0))),
                                              ),
                                              const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 16,
                                                  color: Color.fromARGB(
                                                      165, 0, 0, 0)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: RichText(
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                  text: recentMessageSender ==
                                                          ''
                                                      ? ''
                                                      : '${recentMessageSender.split('_')[1]}: ',
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color.fromARGB(
                                                          190, 0, 0, 0)),
                                                  children: [
                                                    TextSpan(
                                                        text: recentMessage,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromARGB(
                                                                    190,
                                                                    0,
                                                                    0,
                                                                    0))),
                                                  ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        nextScreen(
                                            context,
                                            ChatPage(
                                                groupId: groupId,
                                                groupName: groupName,
                                                username: username));
                                      },
                                    ),
                                  ),
                                  const Divider(
                                    height: 0,
                                    thickness: 0.5,
                                    indent: 30,
                                    endIndent: 30,
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        return const Center(
                            heightFactor: 10,
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                      }
                    }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                String groupName = '';
                return StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                          title: const Text('Create Group',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w600)),
                          content: TextField(
                            onChanged: (value) =>
                                setState(() => groupName = value),
                            decoration:
                                const InputDecoration(hintText: 'Group Name'),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  fixedSize: const Size(76, 32),
                                ),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            TextButton(
                                onPressed: groupName.isNotEmpty
                                    ? () {
                                        setLoading(true);
                                        DatabaseService(
                                                uid: FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            .createGroup(
                                                groupName,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                username)
                                            .whenComplete(() {
                                          setLoading(false);
                                          alertNewGroupCreated(groupName);
                                        });
                                        Navigator.pop(context);
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  fixedSize: const Size(76, 32),
                                  backgroundColor: Colors.blue,
                                  disabledBackgroundColor:
                                      Colors.grey.withOpacity(0.8),
                                ),
                                child: const Text('OK',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                          ],
                        ));
              });
        },
      ),
    );
  }
}
