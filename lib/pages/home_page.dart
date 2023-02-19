import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/widgets.dart';
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
  Stream? groups;
  bool isLoading = false;
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    setState(() => isLoading = true);
    await HelperFunctions.getUserUsername()
        .then((res) => setState(() => username = res!));
    await HelperFunctions.getUserEmail()
        .then((res) => setState(() => email = res!));
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUsersGroups()
        .then((res) => setState(() => groups = res));
    setState(() => isLoading = false);
  }

  void alertNewGroupCreated(String groupName) {
    showSnackBar(
        context, Colors.green, 'Group $groupName created successfully');
  }

  void setLoading(bool val) {
    setState(() => isLoading = val);
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
            const SizedBox(height: 10),
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
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            TextButton(
                                onPressed: () async {
                                  await authService.signOut().whenComplete(() =>
                                      nextScreenReplace(
                                          context, const LoginPage()));
                                },
                                child: const Text('OK',
                                    style: TextStyle(
                                        color: Colors.blue,
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : StreamBuilder(
              stream: groups,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data['groups'] == null ||
                      snapshot.data['groups'].length == 0 ||
                      snapshot.data['groups'].isEmpty ||
                      snapshot.data['groups'] == '') {
                    return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            SizedBox(height: 100),
                            Icon(Icons.group,
                                size: 87.5, color: Colors.black54),
                            SizedBox(height: 10),
                            Text('You are not in any groups yet',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54)),
                            SizedBox(height: 10),
                            Text(
                                'Click on the + button to create a group or search for a group to join',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black38)),
                          ],
                        ));
                  } else {
                    return Text(snapshot.data['groups'].toString());
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                String groupName = '';
                return StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                          title: const Text('Create Group'),
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
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.red,
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
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                groupName,
                                                username)
                                            .whenComplete(
                                                () => setLoading(false));
                                        Navigator.pop(context);
                                        alertNewGroupCreated(groupName);
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  disabledForegroundColor:
                                      Colors.grey.withOpacity(0.8),
                                ),
                                child: const Text('OK',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                          ],
                        ));
              });
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
