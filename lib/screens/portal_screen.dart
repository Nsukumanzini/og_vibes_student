import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  static const String _initialUrl = 'https://gscollege.co.za';

  late final WebViewController _controller;
  double _progress = 0;
  final List<String> _historyLog = <String>[];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            setState(() => _progress = (value.clamp(0, 100) / 100));
          },
          onPageFinished: (url) {
            setState(() {
              _progress = 1;
              _historyLog.add(url);
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Portal')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'The in-app browser is best experienced on mobile. Please use a phone build for full functionality.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07182C),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _controller)),
            _buildSecureHeader(),
            _buildWatermark(),
            _buildBottomNavigation(),
            _buildSmartTools(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureHeader() {
    final headerColor = Colors.green.shade800;
    final isLoading = _progress < 1;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 56,
        color: headerColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Encrypted Connection to GS College',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: isLoading
                  ? LinearProgressIndicator(
                      value: _progress,
                      minHeight: 3,
                      color: Colors.amber,
                      backgroundColor: Colors.transparent,
                    )
                  : const SizedBox(height: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Text(
        'Powered by OG Vibes',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _goBack,
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _controller.reload,
            ),
            IconButton(
              tooltip: 'Forward',
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: _goForward,
            ),
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home_filled, color: Colors.white),
              onPressed: () => _controller.loadRequest(Uri.parse(_initialUrl)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartTools() {
    return Positioned(
      right: 16,
      bottom: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'zoomInFab',
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            onPressed: () => _runZoom('1.1'),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'zoomOutFab',
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            onPressed: () => _runZoom('1.0'),
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'keyFab',
            backgroundColor: const Color(0xFFFFC857),
            onPressed: _copyStudentNumber,
            child: const Icon(Icons.vpn_key_rounded, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  Future<void> _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
    }
  }

  Future<void> _runZoom(String level) async {
    await _controller.runJavaScript("document.body.style.zoom = '$level';");
  }

  Future<void> _copyStudentNumber() async {
    await Clipboard.setData(const ClipboardData(text: '12345678'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student Number Copied! Long press input to paste.'),
      ),
    );
  }
}
