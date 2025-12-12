import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  static const double _linePosition = 0.12;

  late final AnimationController _pulseController;
  late final List<DateTime> _weekDates;
  late final Map<String, List<ClassSession>> _sessionsByDate;
  final DateFormat _timeFormatter = DateFormat('HH:mm');

  bool _isWeekView = false;
  bool _autoMute = false;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDates = _generateWeekDates(_selectedDate);
    _sessionsByDate = {
      for (final date in _weekDates)
        _dateKey(date): _isWeekend(date)
            ? <ClassSession>[]
            : _buildMockSessions(date),
    };

    if (!_sessionsByDate.containsKey(_dateKey(_selectedDate))) {
      _sessionsByDate[_dateKey(_selectedDate)] = _buildMockSessions(
        _selectedDate,
      );
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Timetable'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildDateStrip(),
              const SizedBox(height: 24),
              Expanded(child: _buildSmartList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              _isWeekView ? 'This Week' : 'Today',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildViewDropdown(),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Auto-Mute 🔕',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _autoMute,
                  thumbColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.amber
                        : Colors.white,
                  ),
                  trackColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.amber.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                  onChanged: (value) => setState(() => _autoMute = value),
                ),
              ],
            ),
          ],
        ),
        if (_autoMute)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Phones will auto-mute 5 mins before each session.',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildViewDropdown() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: _isWeekView,
          dropdownColor: Colors.indigo.shade900,
          borderRadius: BorderRadius.circular(18),
          items: const [
            DropdownMenuItem(value: false, child: Text('Day View')),
            DropdownMenuItem(value: true, child: Text('Week View')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _isWeekView = value);
          },
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.expand_more, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDates.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = _weekDates[index];
          final isSelected = _isSameDate(date, _selectedDate);
          final dayLabel = DateFormat('EEE').format(date);
          final dayNumber = DateFormat('d').format(date);
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.amber
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 1.4)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: isSelected ? Colors.black87 : Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? Colors.black87 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartList() {
    if (_isWeekend(_selectedDate)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.beach_access, color: Colors.orangeAccent, size: 80),
            SizedBox(height: 16),
            Text(
              'No Classes - Enjoy the Weekend!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sessions = List<ClassSession>.from(_sessionsForDate(_selectedDate))
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No sessions planned. Tap + to add your classes.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    final nodes = _buildTimelineNodes(sessions);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      physics: const BouncingScrollPhysics(),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final entry = nodes[index];
        if (entry.type == _TimelineNodeType.breakPeriod) {
          return _buildBreakTile(
            isFirst: index == 0,
            isLast: index == nodes.length - 1,
            minutes: entry.gapMinutes,
          );
        }

        final session = entry.session!;
        return _buildClassTile(
          session: session,
          sessions: sessions,
          isFirst: index == 0,
          isLast: index == nodes.length - 1,
        );
      },
    );
  }

  Widget _buildClassTile({
    required ClassSession session,
    required List<ClassSession> sessions,
    required bool isFirst,
    required bool isLast,
  }) {
    final isCurrent = _isCurrentSession(session);
    final hasClash = _hasClash(session, sessions);
    final timeLabel =
        '${_timeFormatter.format(session.startTime)} - '
        '${_timeFormatter.format(session.endTime)}';

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: _linePosition,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 26,
        indicator: _buildIndicator(isCurrent: isCurrent, color: session.color),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.white.withValues(alpha: 0.3),
        thickness: 2.2,
      ),
      afterLineStyle: LineStyle(
        color: Colors.white.withValues(alpha: 0.18),
        thickness: 2.2,
      ),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: session.color.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: session.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      session.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showLocationDialog(session),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Colors.deepOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.room,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _showLecturerDialog(session),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: session.color.withValues(alpha: 0.18),
                      child: Text(
                        session.initials,
                        style: TextStyle(
                          color: session.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        session.lecturer,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.black45,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (hasClash)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Clash! Another class shares this start time.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.black54),
                    onPressed: () => _showNotesSnack(session),
                  ),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Checkbox(
                    value: session.isAttended,
                    fillColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return session.color;
                      }
                      return session.color.withValues(alpha: 0.35);
                    }),
                    checkColor: Colors.white,
                    onChanged: (value) => setState(() {
                      session.isAttended = value ?? false;
                    }),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Attended',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakTile({
    required bool isFirst,
    required bool isLast,
    required int minutes,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineX = constraints.maxWidth * _linePosition;
        return SizedBox(
          height: 130,
          child: Stack(
            children: [
              TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: _linePosition,
                isFirst: isFirst,
                isLast: isLast,
                indicatorStyle: const IndicatorStyle(
                  width: 26,
                  indicator: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text('☕', style: TextStyle(fontSize: 18)),
                  ),
                ),
                beforeLineStyle: const LineStyle(color: Colors.transparent),
                afterLineStyle: const LineStyle(color: Colors.transparent),
                endChild: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Free Period • ${minutes ~/ 60 > 0 ? '${minutes ~/ 60}h ' : ''}${minutes % 60}m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '☕ Free Period – grab a snack or review notes.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: lineX - 1,
                top: 0,
                bottom: 22,
                child: const _DottedConnector(color: Colors.grey, thickness: 2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndicator({required bool isCurrent, required Color color}) {
    if (!isCurrent) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 0.8 + (_pulseController.value * 0.4);
        return Container(
          width: 24 * scale,
          height: 24 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 20 + (_pulseController.value * 10),
                spreadRadius: 4 + (_pulseController.value * 2),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_TimelineEntry> _buildTimelineNodes(List<ClassSession> sessions) {
    final nodes = <_TimelineEntry>[];
    ClassSession? previous;

    for (final session in sessions) {
      if (previous != null) {
        final gapMinutes = session.startTime
            .difference(previous.endTime)
            .inMinutes;
        if (gapMinutes > 30) {
          nodes.add(_TimelineEntry.breakPeriod(gapMinutes));
        }
      }
      nodes.add(_TimelineEntry.session(session));
      previous = session;
    }
    return nodes;
  }

  List<ClassSession> _sessionsForDate(DateTime date) {
    final key = _dateKey(date);
    return _sessionsByDate[key] ?? <ClassSession>[];
  }

  bool _hasClash(ClassSession session, List<ClassSession> sessions) {
    final start = session.startTime;
    final matches = sessions.where((s) => s != session && s.startTime == start);
    return matches.isNotEmpty;
  }

  bool _isCurrentSession(ClassSession session) {
    final now = DateTime.now();
    return now.isAfter(session.startTime) && now.isBefore(session.endTime);
  }

  bool _isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  List<DateTime> _generateWeekDates(DateTime anchor) {
    final startOfWeek = anchor.subtract(
      Duration(days: anchor.weekday - DateTime.monday),
    );
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<ClassSession> _buildMockSessions(DateTime day) {
    final base = DateTime(day.year, day.month, day.day);
    return [
      ClassSession(
        subject: 'Industrial Electronics',
        room: 'Room A22',
        startTime: base.add(const Duration(hours: 8, minutes: 30)),
        endTime: base.add(const Duration(hours: 9, minutes: 45)),
        lecturer: 'Prof. Naledi Dlamini',
        lecturerEmail: 'naledi.dlamini@college.edu',
        locationDetails: 'Building B, 2nd Floor',
        color: const Color(0xFF7B61FF),
      ),
      ClassSession(
        subject: 'Applied Mathematics',
        room: 'Room B11',
        startTime: base.add(const Duration(hours: 10, minutes: 0)),
        endTime: base.add(const Duration(hours: 11, minutes: 30)),
        lecturer: 'Dr. Kabelo Radebe',
        lecturerEmail: 'kabelo.radebe@college.edu',
        locationDetails: 'Building C, Auditorium 1',
        color: const Color(0xFFFFC857),
      ),
      ClassSession(
        subject: 'Digital Systems Lab',
        room: 'Innovation Hub L3',
        startTime: base.add(const Duration(hours: 13, minutes: 30)),
        endTime: base.add(const Duration(hours: 15, minutes: 0)),
        lecturer: 'Eng. Lindi Jacobs',
        lecturerEmail: 'lindi.jacobs@college.edu',
        locationDetails: 'Innovation Hub, Lab 3',
        color: const Color(0xFF4ADE80),
      ),
      ClassSession(
        subject: 'Project Studio',
        room: 'Studio 5',
        startTime: base.add(const Duration(hours: 15, minutes: 15)),
        endTime: base.add(const Duration(hours: 17, minutes: 0)),
        lecturer: 'Mentor Siya Ndlovu',
        lecturerEmail: 'siya.ndlovu@college.edu',
        locationDetails: 'Design Block, Level 1',
        color: const Color(0xFFFF6B6B),
      ),
    ];
  }

  Future<void> _showLocationDialog(ClassSession session) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Details'),
        content: Text('${session.room}\n${session.locationDetails}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLecturerDialog(ClassSession session) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.lecturer),
        content: Text('Email: ${session.lecturerEmail}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotesSnack(ClassSession session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notes for ${session.subject} coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ClassSession {
  ClassSession({
    required this.subject,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.lecturer,
    required this.lecturerEmail,
    required this.locationDetails,
    required this.color,
    this.isAttended = false,
  });

  final String subject;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String lecturer;
  final String lecturerEmail;
  final String locationDetails;
  final Color color;
  bool isAttended;

  String get initials {
    final parts = lecturer.split(' ');
    if (parts.isEmpty) return 'T';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    final firstInitial = parts.first.characters.first;
    final lastInitial = parts.last.characters.first;
    return (firstInitial + lastInitial).toUpperCase();
  }
}

enum _TimelineNodeType { session, breakPeriod }

class _TimelineEntry {
  const _TimelineEntry._(this.type, this.session, this.gapMinutes);

  const _TimelineEntry.session(ClassSession session)
    : this._(_TimelineNodeType.session, session, 0);

  const _TimelineEntry.breakPeriod(int gapMinutes)
    : this._(_TimelineNodeType.breakPeriod, null, gapMinutes);

  final _TimelineNodeType type;
  final ClassSession? session;
  final int gapMinutes;
}

class _DottedConnector extends StatelessWidget {
  const _DottedConnector({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(thickness, constraints.maxHeight),
        painter: _DottedLinePainter(color: color, thickness: thickness),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    const dashHeight = 6.0;
    const dashSpace = 5.0;
    double startY = 0;
    final x = size.width / 2;
    while (startY < size.height) {
      canvas.drawLine(Offset(x, startY), Offset(x, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
