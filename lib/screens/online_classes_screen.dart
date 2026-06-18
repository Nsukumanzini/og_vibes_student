import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'live_classroom_screen.dart';
import 'package:og_vibes_student/models/live_session.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class OnlineClassesScreen extends StatefulWidget {
  const OnlineClassesScreen({super.key});

  @override
  State<OnlineClassesScreen> createState() => _OnlineClassesScreenState();
}

class _OnlineClassesScreenState extends State<OnlineClassesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<void> _initialLoad;

  static const List<String> _moduleFilters = <String>[
    'All',
    'Maths N4',
    'Entrepreneurship N4',
    'Comp Practice N4',
  ];

  String _selectedModule = _moduleFilters.first;
  bool _reminderSet = false;

  static const LiveSession _liveSession = LiveSession(
    subject: 'N4 Entrepreneurship',
    topic: 'Business Plans',
    time: 'Now',
    isLive: true,
    lecturer: 'Mrs. Venter',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialLoad = Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Online Classes')),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          return Column(
            children: <Widget>[
              _buildTopBanner(),
              _buildPinnedModulesRow(),
              const SizedBox(height: 10),
              _buildTabBar(),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _buildLiveNowTab(),
                    _buildUpcomingTab(),
                    _buildRecordingsTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.cast_for_education_rounded, color: Colors.white, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Virtual Campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Join, prepare, and track attendance in one place.',
                  style: TextStyle(
                    color: Color(0xFFE3F2FD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedModulesRow() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _moduleFilters.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (BuildContext context, int index) {
          final String module = _moduleFilters[index];
          final bool selected = module == _selectedModule;
          return ChoiceChip(
            label: Text(module),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() => _selectedModule = module);
            },
            selectedColor: const Color(0xFF1565C0),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? Colors.transparent : const Color(0xFFE0E0E0),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF263238),
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF455A64),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        tabs: const <Tab>[
          Tab(text: 'Live Now'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Recordings'),
        ],
      ),
    );
  }

  Widget _buildLiveNowTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'LIVE: N4 Entrepreneurship',
                style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Lecturer: Mrs. Venter',
                style: TextStyle(
                  color: Color(0xFF455A64),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: const Text(
                  'DHET Rule: 30-Min Minimum Attendance Required',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<Widget>(
                        builder: (_) =>
                            const LiveClassroomScreen(session: _liveSession),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text(
                    'Join Class',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Mathematics N4',
                          style: TextStyle(
                            color: Color(0xFF102027),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Today, 14:00 PM',
                          style: TextStyle(
                            color: Color(0xFF546E7A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleReminder,
                    icon: Icon(
                      _reminderSet
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: _reminderSet
                          ? const Color(0xFFF9A825)
                          : const Color(0xFF607D8B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Pre-Class Materials',
                style: TextStyle(
                  color: Color(0xFF263238),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'N4_Maths_Trigonometry_Slides.pdf (1.2MB)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF37474F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading slides to device...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Download slides',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Office Data Processing - Module 1 Review',
                style: TextStyle(
                  color: Color(0xFF102027),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Recorded on Tuesday, 10:30 AM • Duration: 56 mins',
                style: TextStyle(
                  color: Color(0xFF546E7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAttendanceSheet,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text(
                    'View Class Attendance',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleReminder() {
    setState(() {
      _reminderSet = !_reminderSet;
    });

    if (_reminderSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reminder set! We will notify you 15 minutes before class.',
          ),
        ),
      );
    }
  }

  void _showAttendanceSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Class Roster (45 Attended)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102027),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'You attended this class for 42 minutes. (Present)',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _rosterTile('LM', 'Lerato M. (Present)'),
                _rosterTile('SN', 'Sipho N. (Present)'),
                _rosterTile('DK', 'David K. (Present)'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rosterTile(String initials, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F2FD),
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE3E7EE)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 118,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
