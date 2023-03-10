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
    getCurrentUsername();
    handleGetAllGroups();
  }

  void getCurrentUsername() async {
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

  void handleSearchGroups() async {
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

  void alertChangeGroupStatus(String groupName, bool isLeaving) {
    handleSearchGroups();
    isLeaving
        ? showRichTextSnackBar(context, Colors.red, 'You left ', groupName, '')
        : showRichTextSnackBar(
            context, Colors.green, 'You joined ', groupName, '');
  }

  void handleDeleteGroup(String groupId, String groupName) {
    Navigator.pop(context);
    DatabaseService()
        .deleteGroup(groupId)
        .then((value) => showRichTextSnackBar(
            context, Colors.red, 'You deleted ', groupName, ''))
        .onError((error, _) =>
            showSnackBar(context, Colors.red, error.toString().split('] ')[1]));
    handleSearchGroups();
  }

  bool isGroupMember(List<dynamic> members) {
    return members.contains('${currentUser!.uid}_$currentUsername');
  }

  bool isGroupAdmin(String groupAdmin) {
    return groupAdmin == '${currentUser!.uid}_$currentUsername';
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
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: TextField(
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        suffixIcon: GestureDetector(
                            onTap: () => handleSearchGroups(),
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
                                    radius: 27.5,
                                    backgroundColor: Colors.blueGrey,
                                    child: Text(
                                        currentGroup['groupName'][0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  title: Text(currentGroup['groupName'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 3.5),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                                text: 'Created by ',
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                            TextSpan(
                                                text: searchResults!.docs[index]
                                                        ['groupAdmin']
                                                    .split('_')[1],
                                                style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing:
                                      isGroupMember(currentGroup['members'])
                                          ? isGroupAdmin(
                                                  currentGroup['groupAdmin'])
                                              ? ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder:
                                                            (context) =>
                                                                AlertDialog(
                                                                  title: const Text(
                                                                      'Delete Group',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              21,
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure you want to delete this group?'),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.pop(
                                                                                context),
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                          fixedSize: const Size(
                                                                              76,
                                                                              32),
                                                                        ),
                                                                        child: const Text(
                                                                            'CANCEL',
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          handleDeleteGroup(
                                                                              currentGroup['groupId'],
                                                                              currentGroup['groupName']);
                                                                        },
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          fixedSize: const Size(
                                                                              76,
                                                                              32),
                                                                          backgroundColor:
                                                                              Colors.blue,
                                                                        ),
                                                                        child: const Text(
                                                                            'OK',
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))
                                                                  ],
                                                                ));
                                                  },
                                                  child: const Text('Delete'),
                                                )
                                              : ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blue),
                                                  onPressed: () {
                                                    DatabaseService()
                                                        .leaveGroup(
                                                            currentGroup[
                                                                'groupId'],
                                                            currentGroup[
                                                                'groupName'],
                                                            currentUser!.uid,
                                                            currentUsername)
                                                        .then((value) =>
                                                            alertChangeGroupStatus(
                                                                currentGroup[
                                                                    'groupName'],
                                                                true))
                                                        .onError((error, _) =>
                                                            showSnackBar(
                                                                context,
                                                                Colors.red,
                                                                error
                                                                    .toString()
                                                                    .split(
                                                                        '] ')[1]));
                                                  },
                                                  child: const Text('Leave'),
                                                )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green.shade500),
                                              onPressed: () {
                                                DatabaseService()
                                                    .joinGroup(
                                                        currentGroup['groupId'],
                                                        currentGroup[
                                                            'groupName'],
                                                        currentUser!.uid,
                                                        currentUsername)
                                                    .then((value) =>
                                                        alertChangeGroupStatus(
                                                            currentGroup[
                                                                'groupName'],
                                                            false))
                                                    .onError((error, _) =>
                                                        showSnackBar(
                                                            context,
                                                            Colors.red,
                                                            error
                                                                .toString()
                                                                .split(
                                                                    '] ')[1]));
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
