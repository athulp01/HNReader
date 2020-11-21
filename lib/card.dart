import 'package:flutter/material.dart';
import 'comment.dart';
import 'webview.dart';

class HNItem {
  HNItem(this.headline, this.author, this.votes, this.comments, this.time,
      this.url, this.type, this.childrenID);
  String headline, author, url, type;
  int votes, comments, id, score, time;
  List<dynamic> childrenID;
  List<HNComment> children;
}

class HNCard extends StatelessWidget {
  final HNItem story;

  HNCard(this.story);

  Widget page;

  Widget makeCard(BuildContext context) {
    var before = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(story.time * 1000));
    String timeString = "${before.inHours} hours ago";
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
                  if (story.type == "job" || story.comments == 0)
                    page = Scaffold(
                        appBar: AppBar(
                            title: Text(
                              story.headline,
                            ),
                            backgroundColor: Color(0xffff6600)),
                        body: Center(
                          child: WebViewScreen(story.url),
                        ));
                  if (page == null && story.childrenID != null) {
                    story.children = List(story.childrenID.length);
                    for (var i = 0; i < story.childrenID.length; i++) {
                      story.children[i] = new HNComment(story.childrenID[i], 0);
                    }
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
                      subtitle: Text(
                          "$timeString by ${this.story.author} (${story.url})")),
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
                            Text('${this.story.comments ?? 0}',
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
