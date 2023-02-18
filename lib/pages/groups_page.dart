import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Groups',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
      ),
      body: const Center(
        child: Text('Groups Page'),
      ),
    );
  }
}
