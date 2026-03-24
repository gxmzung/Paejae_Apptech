import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class CampusWebScreen extends StatefulWidget {
  final String title;
  final String url;

  const CampusWebScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<CampusWebScreen> createState() => _CampusWebScreenState();
}

class _CampusWebScreenState extends State<CampusWebScreen> {
  late final WebViewController _c;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
      ),
      body: WebViewWidget(controller: _c),
    );
  }
}