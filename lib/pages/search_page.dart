import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Search',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
      ),
      body: const Center(
        child: Text('Search Page'),
      ),
    );
  }
}
