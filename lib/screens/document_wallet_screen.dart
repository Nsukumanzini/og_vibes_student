import 'package:flutter/material.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class DocumentWalletScreen extends StatefulWidget {
  const DocumentWalletScreen({super.key});

  @override
  State<DocumentWalletScreen> createState() => _DocumentWalletScreenState();
}

class _DocumentWalletScreenState extends State<DocumentWalletScreen> {
  bool _unlocked = false;

  static const List<_WalletDocument> _documents = <_WalletDocument>[
    _WalletDocument(
      title: 'Digital Student ID',
      subtitle: 'Secure campus identity credential',
      icon: Icons.badge_outlined,
      color: Color(0xFF1565C0),
      isId: true,
    ),
    _WalletDocument(
      title: 'Official Proof of Registration (2026)',
      subtitle: 'Institution-approved enrolment proof',
      icon: Icons.assignment_turned_in_outlined,
      color: Color(0xFF00897B),
    ),
    _WalletDocument(
      title: 'NSFAS Bursary Approval Letter',
      subtitle: 'Funding confirmation letter',
      icon: Icons.verified_user_outlined,
      color: Color(0xFF6A1B9A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Secure Document Wallet')),
      body: Stack(
        children: <Widget>[
          _buildWalletContent(),
          if (!_unlocked) _buildLockOverlay(),
        ],
      ),
    );
  }

  Widget _buildWalletContent() {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Text(
            'Your secure campus documents are protected and available offline.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: _documents.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 1.62,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _WalletCard(
                document: _documents[index],
                onView: () => _handleView(_documents[index]),
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating secure PDF share link...'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLockOverlay() {
    return Container(
      color: const Color(0xD9101A26),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE5F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: Color(0xFF0D47A1),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter PIN or Biometrics to unlock Secure Wallet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF102027),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _unlocked = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Secure Wallet unlocked.')),
                    );
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text(
                    'Unlock',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleView(_WalletDocument document) {
    if (document.isId) {
      _showStudentIdSheet();
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening ${document.title}...')));
  }

  void _showStudentIdSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Digital Student ID',
                  style: TextStyle(
                    color: Color(0xFF102027),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 44,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Name: Sipho Ndlovu\nStudent No: TVC-2026-00421\nProgramme: N4 Engineering',
                        style: TextStyle(
                          color: Color(0xFF37474F),
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCFD8E3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '||| ||| |||||| ||| ||||||| |||',
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF102027),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.document,
    required this.onView,
    required this.onShare,
  });

  final _WalletDocument document;
  final VoidCallback onView;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: document.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(document.icon, color: document.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document.title,
                      style: const TextStyle(
                        color: Color(0xFF102027),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      document.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF607D8B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1565C0)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletDocument {
  const _WalletDocument({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isId = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isId;
}
