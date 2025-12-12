import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class SrcVotingScreen extends StatefulWidget {
  const SrcVotingScreen({super.key});

  @override
  State<SrcVotingScreen> createState() => _SrcVotingScreenState();
}

class _SrcVotingScreenState extends State<SrcVotingScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentNumController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ViewState _viewState = ViewState.verification;
  bool _isVerifying = false;
  bool _showBallotCast = false;
  String? _selectedPartyId;

  final List<_Party> _parties = const [
    _Party(
      id: 'sasco',
      name: 'SASCO',
      manifesto: 'Inclusive student leadership with community initiatives.',
      color: Color(0xFFE53935),
      votes: 42,
    ),
    _Party(
      id: 'effsc',
      name: 'EFFSC',
      manifesto: 'Radical transformation and campus justice.',
      color: Color(0xFFD50000),
      votes: 33,
    ),
    _Party(
      id: 'pasma',
      name: 'PASMA',
      manifesto: 'Academic excellence with entrepreneurial focus.',
      color: Color(0xFF1E88E5),
      votes: 25,
    ),
  ];

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _studentNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('SRC Voting Booth')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildActiveStage(),
        ),
      ),
    );
  }

  Widget _buildActiveStage() {
    switch (_viewState) {
      case ViewState.verification:
        return _buildVerificationForm();
      case ViewState.ballot:
        return _buildVotingStep();
      case ViewState.results:
        return _buildResultsOnly();
    }
  }

  Widget _buildVerificationForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Voter Identity Check',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your details to verify eligibility.',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  maxLength: 13,
                  decoration: const InputDecoration(
                    labelText: 'ID Number',
                    hintText: '13-digit South African ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length != 13) {
                      return 'ID must be exactly 13 digits';
                    }
                    if (!RegExp(r'^\d{13}$').hasMatch(trimmed)) {
                      return 'Only digits allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Legal Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (!value.trim().contains(' ')) {
                      return 'Enter name and surname';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentNumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Student Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Student number required';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                      return 'Digits only';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _isVerifying ? null : _handleVerification,
                    child: _isVerifying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Checking Voters Roll...'),
                            ],
                          )
                        : const Text('Verify Eligibility'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVotingStep() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Step 2 · Ballot',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Select one party to cast your vote. This action cannot be changed.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBallotTab()),
          ],
        ),
        if (_showBallotCast)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showBallotCast ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: _BallotCastAnimation(
                    onComplete: () => setState(() {
                      _showBallotCast = false;
                      _viewState = ViewState.results;
                    }),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBallotTab() {
    return ListView.separated(
      itemCount: _parties.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final party = _parties[index];
        final isSelected = party.id == _selectedPartyId;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: party.color.withValues(alpha: 0.15),
                    child: Text(
                      party.name[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    party.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.verified, color: Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                party.manifesto,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: party.color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => _handleVote(party),
                  icon: const Icon(Icons.how_to_vote),
                  label: Text(isSelected ? 'Vote Cast' : 'VOTE X'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsOnly() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _buildResultsCard(),
      ),
    );
  }

  Widget _buildResultsCard() {
    final totalVotes = _parties.fold<int>(0, (sum, party) => sum + party.votes);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Live Vote Distribution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                sections: _parties
                    .map(
                      (party) => PieChartSectionData(
                        color: party.color,
                        value: party.votes.toDouble(),
                        title: totalVotes == 0
                            ? '0%'
                            : '${((party.votes / totalVotes) * 100).toStringAsFixed(0)}%',
                        radius: 70,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._parties.map(
            (party) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: party.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      party.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text('${party.votes} votes'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerification() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _isVerifying = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _viewState = ViewState.ballot;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Identity Verified: You may vote.')),
    );
  }

  Future<void> _handleVote(_Party party) async {
    setState(() {
      _selectedPartyId = party.id;
      _showBallotCast = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ballot cast for ${party.name}.')));
  }
}

class _BallotCastAnimation extends StatefulWidget {
  const _BallotCastAnimation({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_BallotCastAnimation> createState() => _BallotCastAnimationState();
}

class _BallotCastAnimationState extends State<_BallotCastAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dropProgress = Curves.easeOut.transform(_controller.value);
        return Opacity(
          opacity: 1 - _controller.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (dropProgress * 120) - 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.receipt_long, size: 72, color: Colors.blueGrey),
                SizedBox(height: 12),
                Icon(Icons.how_to_vote, size: 48, color: Colors.green),
                SizedBox(height: 8),
                Text(
                  'Ballot Cast',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Party {
  const _Party({
    required this.id,
    required this.name,
    required this.manifesto,
    required this.color,
    required this.votes,
  });

  final String id;
  final String name;
  final String manifesto;
  final Color color;
  final int votes;
}

enum ViewState { verification, ballot, results }
