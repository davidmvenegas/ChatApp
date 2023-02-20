import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Find Groups',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            TextField(
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, size: 26),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
