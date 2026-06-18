import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  static const String _privacyUrl = 'https://ogvibes.com/privacy';

  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) => setState(() => _isLoading = false),
            onNavigationRequest: (request) {
              if (!request.url.startsWith('https://')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_privacyUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web fallback: Show a button to open privacy policy in browser
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacy Policy')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.privacy_tip,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'OG Vibes Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'View our complete privacy policy in your browser.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _launchPrivacyPolicy(),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Privacy Policy'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile: Show WebView
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(_privacyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
