import 'package:flutter/material.dart';
import 'comment.dart';

class HNStory {
  HNStory(this.headline, this.author, this.votes, this.comments);
  String headline, author;
  int votes, comments;
}

class HNCard extends StatefulWidget {
  HNStory story;
  Function checkUpdates;
  int index;
  HNCard(this.story, this.index, this.checkUpdates);
  @override
  HNCardState createState() => HNCardState(story, index, checkUpdates);
}

class HNCardState extends State<HNCard> {
  HNCardState(this.story, this.index, this.checkUpdates);
  Function checkUpdates;
  HNStory story;
  int index;

  void updateState(HNStory stor) {
    setState(() {
      this.story.headline = stor.headline;
      this.story.votes = stor.votes;
    });
  }

  Widget makeCard(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(
                0.8, 0.0), // 10% of the width, so there are ten blinds.
            colors: [
              const Color(0xffff6600),
              const Color(0xffee0000),
            ], // red to yellow
          ),
        ),
        child: Card(
            margin: EdgeInsets.all(1),
            elevation: 10,
            color: Colors.white,
            child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HNComment()));
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
                      subtitle: Text(this.story.author)),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: 90,
                          child: Row(children: [
                            IconButton(
                                icon: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.redAccent[400],
                                ),
                                onPressed: () {
                                  HNStory updated = checkUpdates(index);
                                  updateState(updated);
                                }),
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
                                onPressed: () {
                                  HNStory updated = checkUpdates(index);
                                  updateState(updated);
                                }),
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
