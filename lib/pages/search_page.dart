import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/alerts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  QuerySnapshot? searchResults;
  bool isSearching = false;
  String currentUsername = '';
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    handleGetAllGroups();
  }

  void getCurrentUser() async {
    await HelperFunctions.getUserUsername()
        .then((value) => setState(() => currentUsername = value!));
  }

  void handleGetAllGroups() async {
    setState(() => isSearching = true);
    await DatabaseService().getAllGroups().then((snapshot) {
      setState(() {
        searchResults = snapshot;
        isSearching = false;
      });
    });
  }

  void handleSearchGroups(String query) async {
    if (searchController.text.isNotEmpty) {
      setState(() => isSearching = true);
      await DatabaseService()
          .searchGroups(searchController.text)
          .then((snapshot) {
        setState(() {
          searchResults = snapshot;
          isSearching = false;
        });
      });
    } else {
      handleGetAllGroups();
    }
  }

  bool isGroupMember(List<dynamic> members) {
    return members.contains('${currentUser!.uid}_$currentUsername');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Find Groups',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 6.0, right: 6.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: TextField(
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        suffixIcon: GestureDetector(
                            onTap: () =>
                                handleSearchGroups(searchController.text),
                            child: const Icon(Icons.search, size: 26)),
                        contentPadding: const EdgeInsets.all(16.0),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isSearching
                      ? const Center(
                          heightFactor: 10,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ))
                      : searchResults!.docs.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: searchResults?.docs.length,
                              itemBuilder: (context, index) {
                                QueryDocumentSnapshot<Object?> currentGroup =
                                    searchResults!.docs[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.blue.shade400,
                                    child: Text(
                                        currentGroup['groupName'][0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.5,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  title: Text(currentGroup['groupName'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.5)),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: 'Admin: ',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            )),
                                        TextSpan(
                                            text: searchResults!.docs[index]
                                                    ['groupAdmin']
                                                .split('_')[1],
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            )),
                                      ],
                                    ),
                                  ),
                                  trailing:
                                      isGroupMember(currentGroup['members'])
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () {
                                                DatabaseService().leaveGroup(
                                                    currentGroup['groupId'],
                                                    currentGroup['groupName'],
                                                    currentUsername);
                                              },
                                              child: const Text('Leave'),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green.shade500),
                                              onPressed: () {
                                                DatabaseService().joinGroup(
                                                    currentGroup['groupId'],
                                                    currentGroup['groupName'],
                                                    currentUsername);
                                                showSnackBar(
                                                    context,
                                                    Colors.green,
                                                    'Successfully joined ${currentGroup['groupName']}');
                                              },
                                              child: const Text('Join'),
                                            ),
                                );
                              },
                            )
                          : const Center(
                              heightFactor: 10,
                              child: Text('No results found'),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
