import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String email = '';
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    await HelperFunctions.getUserUsername()
        .then((res) => setState(() => username = res!));
    await HelperFunctions.getUserEmail()
        .then((res) => setState(() => email = res!));
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
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  popUpDialog(BuildContext context) {}

  groupList() {
    // return StreamBuilder(
    //     stream: authService.getGroups(),
    //     builder: (context, AsyncSnapshot<dynamic> snapshot) {
    //       if (snapshot.hasData) {
    //         return ListView.builder(
    //             itemCount: snapshot.data.docs.length,
    //             itemBuilder: (context, index) {
    //               return groupTile(
    //                   snapshot.data.docs[index].data()['groupName'],
    //                   snapshot.data.docs[index].data()['groupDescription'],
    //                   snapshot.data.docs[index].data()['groupIcon'],
    //                   snapshot.data.docs[index].data()['groupAdmin'],
    //                   snapshot.data.docs[index].data()['groupMembers']);
    //             });
    //       } else {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //     });
  }
}
