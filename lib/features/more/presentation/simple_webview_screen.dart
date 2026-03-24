import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class SimpleWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const SimpleWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<SimpleWebViewScreen> createState() => _SimpleWebViewScreenState();
}

class _SimpleWebViewScreenState extends State<SimpleWebViewScreen> {
  late final WebViewController _ctrl;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (!mounted) return;
            setState(() => _progress = p);
          },
          onWebResourceError: (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('웹 페이지를 불러올 수 없어요: ${e.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => _ctrl.reload(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _progress >= 100
              ? const SizedBox(height: 3)
              : LinearProgressIndicator(
            value: _progress / 100.0,
            backgroundColor: Colors.black.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.paejaeBlue.withOpacity(0.95),
            ),
            minHeight: 3,
          ),
        ),
      ),
      body: WebViewWidget(controller: _ctrl),
    );
  }
}