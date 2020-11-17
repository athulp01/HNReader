import 'package:flutter/material.dart';
import 'top.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Tutorial',
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return Scaffold(
      appBar: AppBar(
        title: Text('HackerNews'),
        backgroundColor: Color(0xffff6600),
      ),
      // body is the majority of the screen.
      body: Center(child: HNTop()),
    );
  }
}
