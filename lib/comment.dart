import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'card.dart';
import 'api.dart';
import 'dart:async';
import 'webview.dart';

class HNComment {
  HNComment(this.id, this.left);
  int id;
  double left;
  Future<Map<String, dynamic>> future;
  Widget card;
  List<HNComment> children;
}

class CommentPage extends StatelessWidget {
  final HNStory story;
  List<Widget> cards;
  StreamController<Widget> _controller = StreamController<Widget>.broadcast();

  CommentPage(this.story) {
    cards = new List();
    getComments();
  }

  Widget makeCard(String text, String by, int time, double left) {
    var before = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(story.time * 1000));
    String timeString = "${before.inHours} hours";
    if (before.inHours < 1) {
      timeString = "${before.inMinutes} minutes";
    }
    return Container(
      decoration: BoxDecoration(color: Colors.grey[200]),
      margin: EdgeInsets.only(left: left),
      child: Card(
          child: ListTile(
        dense: true,
        title: Html(data: text),
        subtitle: Text("by $by $timeString ago"),
      )),
    );
  }

  void getComments() async {
    for (var comment in story.children) {
      comment.future = HNAPI.fetchItem(comment.id);
      ListQueue<HNComment> stack = new ListQueue();
      stack.addLast(comment);
      while (stack.isNotEmpty) {
        HNComment top = stack.last;
        stack.removeLast();
        var res = await top.future;
        _controller.add(makeCard(
            res["text"] ?? "deleted", res["by"] ?? "?", res['time'], top.left));
        if (res['kids'] != null) {
          top.children = new List(res["kids"].length);
          for (int i = 0; i < res["kids"].length; i++) {
            top.children[i] = new HNComment(res["kids"][i], top.left + 12);
            top.children[i].future = HNAPI.fetchItem(top.children[i].id);
            stack.addLast(top.children[i]);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${story.headline}"),
            backgroundColor: Color(0xffff6600),
            bottom: TabBar(tabs: [
              Tab(text: "Website"),
              Tab(text: "Comments"),
            ]),
          ),
          body: Center(
              child: TabBarView(children: [
            Container(
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: StreamBuilder(
                    stream: _controller.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        cards.add(snapshot.data);
                        return ListView.builder(
                            itemBuilder: (context, index) {
                              return cards[index];
                            },
                            itemCount: cards.length);
                      } else if (snapshot.connectionState ==
                              ConnectionState.done ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                            itemBuilder: (context, index) {
                              return cards[index];
                            },
                            itemCount: cards.length);
                      }
                      return Text("...");
                    })),
            WebViewScreen(story.url),
          ])),
        ));
  }
}
