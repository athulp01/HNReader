import 'package:flutter/material.dart';
import 'comment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HNStory {
  HNStory(this.headline, this.author, this.votes, this.comments, this.time,
      this.url, this.childrenID);
  String headline, author, url;
  int votes, comments, id, score, time;
  List<dynamic> childrenID;
  List<HNComment> children;
}

class HNCard extends StatelessWidget {
  HNCard(this.story);
  final HNStory story;
  CommentPage page;
  Duration before;
  bool commentSet = false;

  Future<Map<String, dynamic>> fetchItem(int item) async {
    final response =
        await http.get('https://hacker-news.firebaseio.com/v0/item/$item.json');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed');
    }
  }

  Widget makeCard(BuildContext context) {
    before = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(story.time * 1000));
    String timeString = "${before.inHours} hours ago (${story.url}";
    if (before.inHours < 1) {
      timeString = "${before.inMinutes} minutes ago";
    }
    return Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Card(
            margin: EdgeInsets.all(2),
            elevation: 10,
            color: Colors.white,
            child: InkWell(
                onTap: () {
                  if (!commentSet && story.childrenID != null) {
                    story.children = List(story.childrenID.length);
                    for (var i = 0; i < story.childrenID.length; i++) {
                      story.children[i] = new HNComment(story.childrenID[i], 0);
                    }
                    commentSet = true;
                    page = CommentPage(story);
                  }

                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, a1, a2) => page,
                          transitionsBuilder: (c, anim, a2, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: Duration(milliseconds: 300)));
                },
                child: Column(children: [
                  ListTile(
                      title: Text(
                        this.story.headline,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontFamily: "Helvetica"),
                      ),
                      subtitle: Text("$timeString by ${this.story.author}")),
                  Row(
                    children: [
                      Container(
                          width: 90,
                          child: Row(children: [
                            IconButton(
                                icon: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.redAccent[400],
                                ),
                                onPressed: null),
                            Text('${this.story.votes}',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ])),
                      Container(
                          margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                          child: Row(children: [
                            IconButton(
                                icon: Icon(
                                  Icons.comment,
                                  color: Colors.green,
                                ),
                                onPressed: null),
                            Text('${this.story.comments}',
                                style: TextStyle(fontWeight: FontWeight.w600))
                          ])),
                    ],
                  )
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return makeCard(context);
  }
}
