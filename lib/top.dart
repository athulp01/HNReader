import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'card.dart';

class HNTopState extends State<HNTop> {
  Future<Map<String, dynamic>> items;
  Future<List<dynamic>> itemIDs;
  List<HNCard> cards;
  List<HNStory> stories;

  HNCard loading = new HNCard(new HNStory('...', '...', 0, 0, 0, "", null));

  @override
  void initState() {
    super.initState();
    itemIDs = fetchTopItems();
    cards = new List(200);
    stories = new List(200);
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

  Future<List<dynamic>> fetchTopItems() async {
    final response =
        await http.get('https://hacker-news.firebaseio.com/v0/topstories.json');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: itemIDs,
        builder: (contex, snap) {
          if (snap.hasData) {
            return new ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (cards[index] != null) {
                    return cards[index];
                  } else {
                    var item = fetchItem(snap.data[index]);
                    return FutureBuilder<Map<String, dynamic>>(
                        future: item,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            stories[index] = HNStory(
                                snapshot.data['title'],
                                snapshot.data['by'],
                                snapshot.data['score'],
                                snapshot.data['descendants'],
                                snapshot.data['time'],
                                snapshot.data['url'],
                                snapshot.data['kids']);
                            cards[index] = new HNCard(stories[index]);
                            return cards[index];
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return Card(
                              elevation: 10, child: Center(child: loading));
                        });
                  }
                },
                itemCount: 200);
          } else if (snap.hasError) {
            return Text("${snap.error}");
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}

class HNTop extends StatefulWidget {
  @override
  HNTopState createState() => HNTopState();
}
