import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';

class CampusGuideWebViewScreen extends StatefulWidget {
  const CampusGuideWebViewScreen({super.key});

  static const String routeName = '/campusGuideWebView';
  static const String urlCampusGuide = 'https://www.pcu.ac.kr/kor/37/campusGuide';
  static const String urlVrMap = 'https://www.pcu.ac.kr/vr/index.html';

  @override
  State<CampusGuideWebViewScreen> createState() => _CampusGuideWebViewScreenState();
}

class _CampusGuideWebViewScreenState extends State<CampusGuideWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(CampusGuideWebViewScreen.urlCampusGuide));
  }

  Future<void> _go(String url) async {
    setState(() => _loading = true);
    await _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('교내지도', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        actions: [
          IconButton(
            tooltip: '캠퍼스 안내',
            onPressed: () => _go(CampusGuideWebViewScreen.urlCampusGuide),
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            tooltip: 'VR 맵',
            onPressed: () => _go(CampusGuideWebViewScreen.urlVrMap),
            icon: const Icon(Icons.public_rounded),
          ),
          IconButton(
            tooltip: '새로고침',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}