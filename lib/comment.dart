import 'package:flutter/material.dart';

class HNComment extends StatefulWidget {
  @override
  HNCommentState createState() => HNCommentState();
}

class HNCommentState extends State<HNComment> {
  String comment = "Hi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("comments"),
          backgroundColor: Color(0xffff6600),
        ),
        body: Center(
            child: Card(
                child: Column(children: [
          ListTile(
            title: Text(comment),
          ),
        ]))));
  }
}
