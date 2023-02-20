import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  const ProfilePage({Key? key, required this.username, required this.email})
      : super(key: key);
  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Profile',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              const Icon(Icons.account_circle,
                  size: 140, color: Colors.black54),
              const SizedBox(height: 8),
              Text(widget.username,
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
                onTap: () {
                  nextScreen(context, const HomePage());
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.home_rounded,
                    size: 28, color: Colors.black54),
                title: const Text('Home',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ),
              ListTile(
                onTap: () {},
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.person, size: 28, color: Colors.blue),
                title: const Text('Profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue)),
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
                                    await authService.signOut().whenComplete(
                                        () => nextScreenReplace(
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
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.account_circle,
                  size: 140, color: Colors.black54),
              const SizedBox(height: 10),
              const Divider(
                height: 36,
                thickness: .5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Username:',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
                  Text(widget.username,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ],
              ),
              const Divider(
                height: 36,
                thickness: .5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Email:',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
                  Text(widget.email,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ],
              ),
              const Divider(
                height: 36,
                thickness: .5,
              ),
            ],
          ),
        ));
  }
}
