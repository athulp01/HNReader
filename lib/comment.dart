import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'card.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HNComment {
  HNComment(this.id, this.left);
  int id;
  double left;
  Future<Map<String, dynamic>> future;
  Widget card;
  List<HNComment> children;
}

class HNCommentCard extends StatelessWidget {
  HNComment comment;
  List<Widget> wid;
  Future<List<Widget>> future;
  Stopwatch watch;

  HNCommentCard(this.comment) {
    future = getComments();
  }

  Future<List<Widget>> getComments() async {
    print("called");
    watch = new Stopwatch()..start();
    List<Widget> cards = new List();
    double left = 10;
    ListQueue<HNComment> stack = new ListQueue();
    stack.addLast(comment);
    while (stack.isNotEmpty) {
      HNComment top = stack.last;
      stack.removeLast();
      var res = await fetchItem(top.id);
      cards.add(makeCard(res["text"] ?? "deleted", top.left));
      if (res['kids'] != null) {
        for (int i = 0; i < res["kids"].length; i++) {
          stack.addLast(HNComment(res["kids"][i], left));
        }
      }
      left += 10;
    }
    return cards;
  }

  Future<Map<String, dynamic>> fetchItem(int item) async {
    final response =
        await http.get('https://hacker-news.firebaseio.com/v0/item/$item.json');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed');
    }
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
            return Column(children: snapshot.data);
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
