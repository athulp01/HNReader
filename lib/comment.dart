import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'card.dart';
import 'package:flutter/foundation.dart';
import 'api.dart';

class HNComment {
  HNComment(this.id, this.left);
  int id;
  double left;
  Future<Map<String, dynamic>> future;
  Widget card;
  List<HNComment> children;
}

class HNCommentCard extends StatelessWidget {
  final HNComment comment;
  List<Widget> wid;
  Future<List<Widget>> future;

  HNCommentCard(this.comment) {
    comment.future = HNAPI.fetchItem(comment.id);
    future = getComments();
  }

  Future<List<Widget>> getComments() async {
    List<Widget> cards = new List();
    ListQueue<HNComment> stack = new ListQueue();
    stack.addLast(comment);
    while (stack.isNotEmpty) {
      HNComment top = stack.last;
      stack.removeLast();
      var res = await top.future;
      cards.add(makeCard(res["text"] ?? "deleted", top.left));
      if (res['kids'] != null) {
        top.children = new List(res["kids"].length);
        for (int i = 0; i < res["kids"].length; i++) {
          top.children[i] = new HNComment(res["kids"][i], top.left+10);
          top.children[i].future = HNAPI.fetchItem(top.children[i].id);
          stack.addLast(top.children[i]);

        }
      }
    }
    return cards;
  }

  Widget makeCard(String text, double left) {
    return Container(
      margin: EdgeInsets.only(left: left),
      child: Card(child: ListTile(dense: true, title: Html(data: text))),
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
        future: this.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (wid == null) wid = snapshot.data;
            return SingleChildScrollView(child:Column(children: snapshot.data));
          } else {
            return Card(child: Center(child: Text("...")));
          }
        });
  }
}

class CommentPage extends StatelessWidget {
  final HNStory story;
  List<HNCommentCard> cards;

  CommentPage(this.story) {
    WebView.platform = SurfaceAndroidWebView();
    cards = new List(story.children.length);
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
              Tab(text: "Comments"),
              Tab(text: "Url"),
            ]),
          ),
          body: Center(
              child: TabBarView(children: [
            ListView.builder(
              itemBuilder: (context, index) {
                if (cards[index] == null)
                  cards[index] = HNCommentCard(story.children[index]);
                return cards[index];
              },
              itemCount: story.children.length,
            ),
            WebView(
              gestureRecognizers: [
                Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer())
              ].toSet(),
              initialUrl: story.url,
            )
          ])),
        ));
  }
}
