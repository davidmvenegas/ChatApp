import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:flutter/material.dart';

// TEXT INPUT DECORATION
const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  ),
);

// GROUP TILE
class GroupTile extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String username;
  const GroupTile(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.username})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 0.0),
      elevation: 1.5,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black12,
          width: 0.25,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: ListTile(
        leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.blue[100],
            child: Text(
              widget.groupName[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            )),
        title: Text(widget.groupName),
        subtitle: Text(widget.username),
        onTap: () {
          nextScreen(
              context,
              ChatPage(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  username: widget.username));
        },
      ),
    );
  }
}
