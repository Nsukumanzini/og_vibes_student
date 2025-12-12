import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpfulContactsScreen extends StatefulWidget {
  const HelpfulContactsScreen({super.key});

  @override
  State<HelpfulContactsScreen> createState() => _HelpfulContactsScreenState();
}

class _HelpfulContactsScreenState extends State<HelpfulContactsScreen> {
  final TextEditingController _ussdController = TextEditingController();

  final List<Contact> _crisisContacts = [
    Contact(
      name: 'Gender Based Violence Command',
      number: '0800428428',
      type: ContactType.crisis,
      isGBV: true,
    ),
    Contact(
      name: 'SADAG (Mental Health)',
      number: '0800567567',
      smsNumber: '31393',
      type: ContactType.crisis,
    ),
    Contact(
      name: 'Poison Control',
      number: '0861555777',
      type: ContactType.crisis,
    ),
  ];

  final List<Contact> _adminContacts = [
    Contact(
      name: 'Finance Office',
      number: '0178115824',
      type: ContactType.admin,
      openTime: const TimeOfDay(hour: 8, minute: 0),
      closeTime: const TimeOfDay(hour: 15, minute: 30),
    ),
    Contact(
      name: 'NSFAS Wallet',
      number: '0800067327',
      type: ContactType.admin,
      subtitle: 'For Wallet/Allowance Issues',
    ),
  ];

  @override
  void dispose() {
    _ussdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Smart Support Hub')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF2962FF), Color(0xFF6200EA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUssdGenerator(),
                const SizedBox(height: 28),
                _buildCrisisSection(),
                const SizedBox(height: 28),
                _buildAdminSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUssdGenerator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No Airtime?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Generate a Please Call Me via USSD.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ussdController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter number to request call',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.phone_callback,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _sendPleaseCall,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Send\nPlease Call Me',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisSection() {
    final gbv = _crisisContacts.firstWhere((c) => c.isGBV);
    final sadag = _crisisContacts.firstWhere((c) => c.smsNumber != null);
    final poison = _crisisContacts.firstWhere((c) => c.name.contains('Poison'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crisis Lines',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _crisisCard(
          contact: gbv,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFE040FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.health_and_safety,
          actions: [
            _pillButton('Call', Icons.phone, () => _launchCall(gbv.number)),
          ],
        ),
        const SizedBox(height: 16),
        _crisisCard(
          contact: sadag,
          gradient: const LinearGradient(
            colors: [Color(0xFF00695C), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.support_agent,
          actions: [
            _pillButton('Call', Icons.phone, () => _launchCall(sadag.number)),
            _pillButton(
              'SMS',
              Icons.sms,
              () => _launchSms(sadag.smsNumber ?? sadag.number),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _crisisCard(
          contact: poison,
          color: const Color(0xFFC62828),
          icon: Icons.warning_amber_rounded,
          actions: [
            _pillButton('Call', Icons.phone, () => _launchCall(poison.number)),
          ],
        ),
      ],
    );
  }

  Widget _crisisCard({
    required Contact contact,
    required IconData icon,
    required List<Widget> actions,
    Gradient? gradient,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 8, children: actions),
        ],
      ),
    );
  }

  Widget _pillButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    );
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus Admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _adminContacts.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final contact = _adminContacts[index];
            final open = _isOpen(contact);
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: _glassDecoration(),
              child: Row(
                children: [
                  const Icon(Icons.apartment, color: Colors.white70, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.subtitle ?? contact.number,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (contact.openTime != null &&
                            contact.closeTime != null)
                          Text(
                            'Hours: ${_formatTime(contact.openTime)} - ${_formatTime(contact.closeTime)}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: open ? Colors.greenAccent : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        open ? 'OPEN' : 'CLOSED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _launchCall(contact.number),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amberAccent,
                        ),
                        child: const Text('Call'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isOpen(Contact contact) {
    if (contact.openTime == null || contact.closeTime == null) {
      return false;
    }

    final now = DateTime.now();
    if (now.weekday < DateTime.monday || now.weekday > DateTime.friday) {
      return false;
    }

    final open = DateTime(
      now.year,
      now.month,
      now.day,
      contact.openTime!.hour,
      contact.openTime!.minute,
    );
    final close = DateTime(
      now.year,
      now.month,
      now.day,
      contact.closeTime!.hour,
      contact.closeTime!.minute,
    );

    return !now.isBefore(open) && !now.isAfter(close);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final date = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat('HH:mm').format(date);
  }

  Future<void> _sendPleaseCall() async {
    final raw = _ussdController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a number first.')));
      return;
    }

    final sanitized = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:*121*$sanitized%23');
    await _launchUri(uri);
  }

  Future<void> _launchCall(String number) async {
    await _launchUri(Uri.parse('tel:$number'));
  }

  Future<void> _launchSms(String number) async {
    await _launchUri(Uri.parse('sms:$number'));
  }

  Future<void> _launchUri(Uri uri) async {
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to launch right now.')),
        );
      }
    }
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

enum ContactType { crisis, admin }

class Contact {
  Contact({
    required this.name,
    required this.number,
    required this.type,
    this.openTime,
    this.closeTime,
    this.isGBV = false,
    this.smsNumber,
    this.ussdCode,
    this.subtitle,
  });

  final String name;
  final String number;
  final ContactType type;
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final bool isGBV;
  final String? smsNumber;
  final String? ussdCode;
  final String? subtitle;
}
