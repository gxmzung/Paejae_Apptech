// lib/features/more/presentation/campus_guide_web_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';

class CampusGuideWebScreen extends StatefulWidget {
  const CampusGuideWebScreen({super.key});

  static const String routeName = '/campusGuideWeb';
  static const String campusGuideUrl = 'https://www.pcu.ac.kr/kor/37/campusGuide';
  static const String vrMapUrl = 'https://www.pcu.ac.kr/vr/index.html';

  @override
  State<CampusGuideWebScreen> createState() => _CampusGuideWebScreenState();
}

class _CampusGuideWebScreenState extends State<CampusGuideWebScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  late final WebViewController _guideCtrl;
  late final WebViewController _vrCtrl;

  bool _loadingGuide = true;
  bool _loadingVr = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    _guideCtrl = _buildCtrl(
      url: CampusGuideWebScreen.campusGuideUrl,
      onStart: () => setState(() => _loadingGuide = true),
      onFinish: () => setState(() => _loadingGuide = false),
    );

    _vrCtrl = _buildCtrl(
      url: CampusGuideWebScreen.vrMapUrl,
      onStart: () => setState(() => _loadingVr = true),
      onFinish: () => setState(() => _loadingVr = false),
    );
  }

  WebViewController _buildCtrl({
    required String url,
    required VoidCallback onStart,
    required VoidCallback onFinish,
  }) {
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => onStart(),
          onPageFinished: (_) => onFinish(),
          onWebResourceError: (e) {
            // 로딩 실패 표시
            onFinish();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('페이지 로드 실패: ${e.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return ctrl;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _reloadCurrent() async {
    if (_tab.index == 0) {
      await _guideCtrl.reload();
    } else {
      await _vrCtrl.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb; // Web에선 webview_flutter 제약이 있을 수 있음

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('교내지도', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        bottom: TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: '교내안내'),
            Tab(text: 'VR 항공뷰'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _reloadCurrent,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: isWeb
          ? _WebFallback() // 웹에서는 제한 가능 → 안내만 띄움
          : TabBarView(
        controller: _tab,
        children: [
          _WebCard(
            loading: _loadingGuide,
            child: WebViewWidget(controller: _guideCtrl),
          ),
          _WebCard(
            loading: _loadingVr,
            child: WebViewWidget(controller: _vrCtrl),
          ),
        ],
      ),
    );
  }
}

class _WebCard extends StatelessWidget {
  final bool loading;
  final Widget child;
  const _WebCard({required this.loading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: child),
            if (loading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _WebFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Web에선 webview가 제한될 수 있어 안내만 (외부 브라우저는 원하면 버튼으로 바꿔줄게)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: const Text(
          '웹(Web) 환경에서는 앱 내 WebView가 제한될 수 있어요.\n'
              '모바일/데스크톱 앱에서 “교내지도”를 이용해주세요.',
          style: TextStyle(fontWeight: FontWeight.w900, height: 1.35),
        ),
      ),
    );
  }
}