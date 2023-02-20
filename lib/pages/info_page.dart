import 'package:chat_app/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAdmin;

  const InfoPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.groupAdmin})
      : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Stream? currentGroup;

  @override
  void initState() {
    super.initState();
    getInfoData();
  }

  void getInfoData() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroup(widget.groupId)
        .then((res) => setState(() => currentGroup = res));
  }

  String extractId(String res) => res.substring(0, res.indexOf("_"));
  String extractName(String res) => res.substring(res.indexOf("_") + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Group Info',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group: ${widget.groupName}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 26)),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Members:',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.black)),
                  const SizedBox(height: 20),
                  StreamBuilder(
                    stream: currentGroup,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data['members'].length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            String cleanedName =
                                extractName(snapshot.data['members'][index]);
                            String memberName =
                                cleanedName == extractName(widget.groupAdmin)
                                    ? '$cleanedName (Admin)'
                                    : cleanedName;
                            String memberId =
                                extractId(snapshot.data['members'][index]);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    memberName[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(memberName),
                                subtitle: Text(memberId),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                            heightFactor: 10,
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                      }
                    },
                  )
                ])
          ],
        ),
      ),
    );
  }
}
