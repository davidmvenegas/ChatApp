import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/alerts.dart';
import 'package:chat_app/widgets/components.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String email = '';
  Stream? userData;
  bool isLoading = false;
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
        .getUserData()
        .then((res) => setState(() => userData = res));
    setState(() => isLoading = false);
  }

  void alertNewGroupCreated(String groupName) {
    showRichTextSnackBar(
        context, Colors.green, '', groupName, ' successfully created');
  }

  void setLoading(bool val) {
    setState(() => isLoading = val);
  }

  String extractId(String res) => res.substring(0, res.indexOf('_'));
  String extractName(String res) => res.substring(res.indexOf('_') + 1);

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
              padding: EdgeInsets.only(top: 15, bottom: 8, left: 20, right: 20),
              child: Text('Messages',
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
                : StreamBuilder(
                    stream: userData,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data['groups'].length == 0) {
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
                            itemCount: snapshot.data['groups'].length,
                            itemBuilder: (context, index) {
                              int reverseIndex =
                                  snapshot.data['groups'].length - index - 1;
                              return GroupTile(
                                  groupId: extractId(
                                      snapshot.data['groups'][reverseIndex]),
                                  groupName: extractName(
                                      snapshot.data['groups'][reverseIndex]),
                                  username: username);
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
