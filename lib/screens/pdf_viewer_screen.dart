import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerScreen({super.key, required this.url, this.title = 'Document'});

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open URL')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openInBrowser(context),
          ),
        ],
      ),
      body: SfPdfViewer.network(
        url,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
