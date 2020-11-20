import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class WebViewScreen extends StatefulWidget {
  String url;
  WebViewScreen(this.url) {
    WebView.platform = SurfaceAndroidWebView();
  }

  WebViewState createState() => WebViewState(url);
}

class WebViewState extends State<WebViewScreen> {
  String url;
  bool isLoading = true;

  WebViewState(this.url);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        WebView(
          initialUrl: this.url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (finish) {
            setState(() {
              isLoading = false;
            });
          },
          gestureRecognizers: [
            Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())
          ].toSet(),
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(),
      ],
    );
  }
}
