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
  List<HNComment> children;
}

class CommentPage extends StatefulWidget {
  final HNStory _story;

  CommentPage(this._story);

  CommentPageState createState() => CommentPageState(_story);
}

class CommentPageState extends State<CommentPage> {
  final HNStory _story;
  List<Widget> _cards;

  CommentPageState(this._story) {
    _cards = new List(_story.comments);
    getComments();
  }

  void initState() {
    super.initState();
    var loading = _makeCard("...", "...", 0, 0);
    for (int i = 0; i < _story.comments; i++) {
      _cards[i] = loading;
    }
  }

  Widget _makeCard(String text, String by, int time, double left) {
    var before = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(time * 1000));
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
    int j = 0;
    for (var comment in _story.children) {
      comment.future = HNAPI.fetchItem(comment.id);
      ListQueue<HNComment> stack = new ListQueue();
      stack.addLast(comment);
      while (stack.isNotEmpty) {
        HNComment top = stack.last;
        stack.removeLast();
        var res = await top.future;
        setState(() {
          if (j < _story.comments) {
            _cards[j] = _makeCard(res["text"] ?? "deleted", res["by"] ?? "?",
                res['time'], top.left);
            j++;
          }
        });
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
            title: Text("${_story.headline}"),
            backgroundColor: Color(0xffff6600),
            bottom: TabBar(tabs: [
              Tab(text: "Website"),
              Tab(text: "Comments"),
            ]),
          ),
          body: Center(
              child: TabBarView(children: [
            WebViewScreen(_story.url),
            Container(
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: ListView.builder(
                    itemBuilder: (context, index) {
                      return _cards[index];
                    },
                    itemCount: _cards.length)),
          ])),
        ));
  }
}
