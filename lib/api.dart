import 'package:http/http.dart' as http;
import 'dart:convert';

class HNAPI {
  static final client = http.Client();

  static Future<Map<String, dynamic>> fetchItem(int item) async {
    final response = await client
        .get('https://hacker-news.firebaseio.com/v0/item/$item.json');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed');
    }
  }

  static Future<List<dynamic>> fetchTopItems() async {
    final response = await client
        .get('https://hacker-news.firebaseio.com/v0/topstories.json');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed');
    }
  }
}
