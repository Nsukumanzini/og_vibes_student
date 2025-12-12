import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class StudyResourcesScreen extends StatefulWidget {
  const StudyResourcesScreen({super.key});

  @override
  State<StudyResourcesScreen> createState() => _StudyResourcesScreenState();
}

class _StudyResourcesScreenState extends State<StudyResourcesScreen> {
  final List<_VaultResource> _vaultResources = const [
    _VaultResource(
      subject: 'MATH N4',
      year: '2023',
      qpUrl:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      memoUrl: 'https://www.africau.edu/images/default/sample.pdf',
      difficulty: 3,
      sizeMb: 9.2,
    ),
    _VaultResource(
      subject: 'ENG SCI N3',
      year: '2022',
      qpUrl: 'https://www.orimi.com/pdf-test.pdf',
      memoUrl: 'https://gahp.net/wp-content/uploads/2017/09/sample.pdf',
      difficulty: 4,
      sizeMb: 12.4,
    ),
    _VaultResource(
      subject: 'ELECTRO N3',
      year: '2023',
      qpUrl:
          'https://file-examples.com/storage/fe7f4c26dc5d07cca908a87/2017/10/file-sample_150kB.pdf',
      memoUrl:
          'https://file-examples.com/storage/fe7f4c26dc5d07cca908a87/2017/10/file-example_PDF_500_kB.pdf',
      difficulty: 2,
      sizeMb: 7.8,
    ),
    _VaultResource(
      subject: 'INDUS ELEC N4',
      year: '2021',
      qpUrl: 'https://www.orimi.com/pdf-test.pdf',
      memoUrl:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      difficulty: 5,
      sizeMb: 15.0,
    ),
  ];

  final Map<String, _VaultMode> _selectedModes = {};
  final Map<String, _DownloadState> _downloadStates = {};
  final Map<String, Timer> _activeTimers = {};

  List<FileSystemEntity> _backpackFiles = <FileSystemEntity>[];
  bool _isLoadingBackpack = false;

  @override
  void initState() {
    super.initState();
    _loadBackpackFiles();
  }

  @override
  void dispose() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: VibeScaffold(
        appBar: AppBar(
          title: const Text('The Vault', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            tabs: [
              Tab(text: '☁️ Online Vault'),
              Tab(text: '🎒 My Backpack (Offline)'),
            ],
          ),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D47A1), Color(0xFF6200EA)],
            ),
          ),
          child: TabBarView(
            children: [_buildOnlineVault(), _buildBackpackTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineVault() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.75,
        ),
        itemCount: _vaultResources.length,
        itemBuilder: (context, index) {
          final resource = _vaultResources[index];
          final mode = _selectedModes[resource.id] ?? _VaultMode.qp;
          return _GlassLockerCard(
            resource: resource,
            mode: mode,
            downloadState: _downloadStates[_downloadKey(resource, mode)],
            onModeChanged: (selection) =>
                setState(() => _selectedModes[resource.id] = selection),
            onDownload: () => _startDownload(resource),
            onOpen: () => _openResource(resource, fromLocal: true),
            onShare: () => _shareResource(resource),
            onPreview: () => _openResource(resource, fromLocal: false),
          );
        },
      ),
    );
  }

  Widget _buildBackpackTab() {
    if (_isLoadingBackpack) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_backpackFiles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'No offline files yet. Download from the Vault to fill your Backpack.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBackpackFiles,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _backpackFiles.length,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final file = _backpackFiles[index];
          final stat = file.statSync();
          final sizeMb = stat.size / (1024 * 1024);
          final name = file.path.split(Platform.pathSeparator).last;
          return ListTile(
            tileColor: Colors.white.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: const Icon(Icons.picture_as_pdf, color: Colors.amber),
            title: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${sizeMb.toStringAsFixed(2)} MB',
              style: const TextStyle(color: Colors.white60),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white70),
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(files: [XFile(file.path)], text: name),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.white70),
                  onPressed: () => _openLocalFile(file.path, name),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _startDownload(_VaultResource resource) async {
    final mode = _selectedModes[resource.id] ?? _VaultMode.qp;
    final key = _downloadKey(resource, mode);
    final existing = _downloadStates[key];
    if (existing != null &&
        existing.status == VaultDownloadStatus.downloading) {
      return;
    }

    setState(() {
      _downloadStates[key] = _DownloadState(
        status: VaultDownloadStatus.downloading,
        progress: 0,
      );
    });

    final timer = Timer.periodic(const Duration(milliseconds: 250), (
      timer,
    ) async {
      final current = _downloadStates[key];
      if (current == null ||
          current.status != VaultDownloadStatus.downloading) {
        timer.cancel();
        return;
      }
      final updated = (current.progress + 0.08).clamp(0.0, 1.0);
      setState(() {
        _downloadStates[key] = current.copyWith(progress: updated);
      });
      if (updated >= 1) {
        timer.cancel();
        final localPath = await _writeMockFile(resource, mode);
        setState(() {
          _downloadStates[key] = _DownloadState(
            status: VaultDownloadStatus.downloaded,
            progress: 1,
            localPath: localPath,
          );
        });
        await _loadBackpackFiles();
      }
    });

    _activeTimers[key]?.cancel();
    _activeTimers[key] = timer;
  }

  Future<String> _writeMockFile(
    _VaultResource resource,
    _VaultMode mode,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final sanitized = resource.subject.replaceAll(' ', '_');
    final filename = '${sanitized}_${resource.year}_${mode.name}.pdf';
    final file = File('${dir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(List<int>.generate(2048, (index) => index % 256));
    return file.path;
  }

  Future<void> _shareResource(_VaultResource resource) async {
    final mode = _selectedModes[resource.id] ?? _VaultMode.qp;
    final key = _downloadKey(resource, mode);
    final state = _downloadStates[key];
    if (state == null || state.localPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download the file before sharing.')),
      );
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(state.localPath!)],
        text: '${resource.subject} ${resource.year} (${mode.label})',
      ),
    );
  }

  Future<void> _openResource(
    _VaultResource resource, {
    required bool fromLocal,
  }) async {
    final mode = _selectedModes[resource.id] ?? _VaultMode.qp;
    if (fromLocal) {
      final key = _downloadKey(resource, mode);
      final local = _downloadStates[key]?.localPath;
      if (local == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download first to open offline.')),
        );
        return;
      }
      return _openLocalFile(local, '${resource.subject} ${resource.year}');
    }

    final url = mode == _VaultMode.qp ? resource.qpUrl : resource.memoUrl;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          title: '${resource.subject} ${resource.year}',
          source: url,
          isLocal: false,
        ),
      ),
    );
  }

  Future<void> _openLocalFile(String path, String title) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PdfViewerScreen(title: title, source: path, isLocal: true),
      ),
    );
  }

  Future<void> _loadBackpackFiles() async {
    setState(() => _isLoadingBackpack = true);
    final dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) {
      setState(() {
        _backpackFiles = <FileSystemEntity>[];
        _isLoadingBackpack = false;
      });
      return;
    }

    final files = dir
        .listSync()
        .where(
          (entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.pdf'),
        )
        .toList();

    setState(() {
      _backpackFiles = files;
      _isLoadingBackpack = false;
    });
  }

  String _downloadKey(_VaultResource resource, _VaultMode mode) =>
      '${resource.id}-${mode.name}';
}

class _GlassLockerCard extends StatelessWidget {
  const _GlassLockerCard({
    required this.resource,
    required this.mode,
    required this.downloadState,
    required this.onModeChanged,
    required this.onDownload,
    required this.onOpen,
    required this.onShare,
    required this.onPreview,
  });

  final _VaultResource resource;
  final _VaultMode mode;
  final _DownloadState? downloadState;
  final ValueChanged<_VaultMode> onModeChanged;
  final VoidCallback onDownload;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final isDownloading =
        downloadState?.status == VaultDownloadStatus.downloading;
    final isDownloaded =
        downloadState?.status == VaultDownloadStatus.downloaded &&
        downloadState?.localPath != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      resource.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      resource.year,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<_VaultMode>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  side: WidgetStateProperty.all(
                    BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                segments: const [
                  ButtonSegment<_VaultMode>(
                    value: _VaultMode.qp,
                    label: Text('QP'),
                  ),
                  ButtonSegment<_VaultMode>(
                    value: _VaultMode.memo,
                    label: Text('MEMO'),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (value) => onModeChanged(value.first),
              ),
              const SizedBox(height: 12),
              _DifficultyMeter(score: resource.difficulty),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${resource.sizeMb.toStringAsFixed(1)} MB',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    onPressed: onPreview,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: isDownloaded ? Colors.white : Colors.white24,
                    ),
                    onPressed: isDownloaded ? onShare : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isDownloading)
                SizedBox(
                  height: 42,
                  child: LiquidLinearProgressIndicator(
                    value: downloadState?.progress ?? 0,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4AD7D1)),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    borderRadius: 12,
                    center: Text(
                      'Downloading ${(100 * (downloadState?.progress ?? 0)).round()}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else if (isDownloaded)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF35C759),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onOpen,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Open'),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filledTonal(
                    onPressed: onDownload,
                    padding: const EdgeInsets.all(10),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyMeter extends StatelessWidget {
  const _DifficultyMeter({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < score;
        final color =
            Color.lerp(
              const Color(0xFF22C55E),
              const Color(0xFFFF3B30),
              index / 4,
            ) ??
            Colors.white;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
            height: 6,
            decoration: BoxDecoration(
              color: filled ? color : Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({
    required this.title,
    required this.source,
    required this.isLocal,
    super.key,
  });

  final String title;
  final String source;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final viewer = isLocal
        ? SfPdfViewer.file(File(source))
        : SfPdfViewer.network(source);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          Positioned.fill(child: viewer),
          IgnorePointer(
            child: Center(
              child: Transform.rotate(
                angle: -0.5,
                child: const Text(
                  'Downloaded via OG Vibes',
                  style: TextStyle(
                    color: Colors.white12,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultResource {
  const _VaultResource({
    required this.subject,
    required this.year,
    required this.qpUrl,
    required this.memoUrl,
    required this.difficulty,
    required this.sizeMb,
  });

  final String subject;
  final String year;
  final String qpUrl;
  final String memoUrl;
  final int difficulty;
  final double sizeMb;

  String get id => '$subject-$year';
}

class _DownloadState {
  const _DownloadState({
    required this.status,
    required this.progress,
    this.localPath,
  });

  final VaultDownloadStatus status;
  final double progress;
  final String? localPath;

  _DownloadState copyWith({
    VaultDownloadStatus? status,
    double? progress,
    String? localPath,
  }) => _DownloadState(
    status: status ?? this.status,
    progress: progress ?? this.progress,
    localPath: localPath ?? this.localPath,
  );
}

enum VaultDownloadStatus { idle, downloading, downloaded }

enum _VaultMode { qp, memo }

extension on _VaultMode {
  String get label => this == _VaultMode.qp ? 'QP' : 'MEMO';
}
