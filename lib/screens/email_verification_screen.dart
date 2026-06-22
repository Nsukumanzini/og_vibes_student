import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../widgets/vibe_scaffold.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  bool _isSending = false;
  int _cooldownSeconds = 0;
  int _resendAttempts = 0;
  DateTime? _resendWindowStart;
  bool _verificationComplete = false;
  final int _resendLimit = 3;

  final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$',
  );

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _isSending) return;
    _resetResendWindowIfNeeded();
    if (_cooldownSeconds > 0) return;
    if (_resendAttempts >= _resendLimit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resend limit reached. Try again later.')),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('No email available for verification.');
      }
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      if (!mounted) return;
      _resendAttempts += 1;
      _startCooldown();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification email sent!')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send email.')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
        return;
      }
      setState(() => _cooldownSeconds -= 1);
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _pollTimer?.cancel();
        return;
      }
      if (user.emailConfirmedAt != null && mounted) {
        await _handleVerified();
      }
    });
  }

  Future<void> _handleManualCheck() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You are not signed in.')));
      return;
    }
    if (user.emailConfirmedAt != null && mounted) {
      await _handleVerified();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not verified yet!')));
    }
  }

  void _resetResendWindowIfNeeded() {
    final now = DateTime.now();
    if (_resendWindowStart == null) {
      _resendWindowStart = now;
      return;
    }
    if (now.difference(_resendWindowStart!).inMinutes >= 60) {
      _resendWindowStart = now;
      _resendAttempts = 0;
    }
  }

  Future<void> _handleVerified() async {
    if (_verificationComplete) return;
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    if (!mounted) return;
    setState(() => _verificationComplete = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _showChangeEmailDialog() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final controller = TextEditingController(text: user.email ?? '');
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change email'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'New email'),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final nextEmail = controller.text.trim();
                          if (!_emailRegex.hasMatch(nextEmail)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid email address.'),
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            await Supabase.instance.client.auth.updateUser(
                              UserAttributes(email: nextEmail),
                            );
                            await Supabase.instance.client
                                .from('public.profiles')
                                .update({'email': nextEmail})
                                .eq('id', user.id);
                            if (!mounted) return;
                            if (!dialogContext.mounted) return;
                            _resendAttempts = 0;
                            _resendWindowStart = DateTime.now();
                            _startCooldown();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email updated. Check inbox.'),
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                          } catch (error) {
                            if (!mounted) return;
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.toString(),
                                ),
                              ),
                            );
                          } finally {
                            if (mounted && dialogContext.mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'your email';
    final theme = Theme.of(context);

    return VibeScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: _verificationComplete ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _verificationComplete
                        ? Icons.verified_rounded
                        : Icons.mark_email_unread,
                    size: 86,
                    color: _verificationComplete
                        ? Colors.greenAccent
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _verificationComplete ? 'Email verified' : 'Check your Inbox',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _verificationComplete
                      ? 'You are all set. Taking you to the app...'
                      : 'We sent a verification link to\n$email. You must verify it to continue.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildChecklist(),
                const SizedBox(height: 24),
                Semantics(
                  label: 'Resend verification email',
                  button: true,
                  child: ElevatedButton(
                    onPressed: _isSending || _cooldownSeconds > 0
                        ? null
                        : _sendVerificationEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD740),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _cooldownSeconds > 0
                                ? 'Resend in ${_cooldownSeconds}s'
                                : 'Resend email (${_resendLimit - _resendAttempts} left)',
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'I have verified my email',
                  button: true,
                  child: OutlinedButton(
                    onPressed: _handleManualCheck,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('I have verified'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _showChangeEmailDialog,
                  child: const Text('Change email address'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _handleSignOut,
                  child: const Text('Cancel / Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return Column(
      children: const [
        _ChecklistItem(
          icon: Icons.mail_outline,
          text: 'Check your inbox (and spam folder).',
        ),
        SizedBox(height: 8),
        _ChecklistItem(
          icon: Icons.link,
          text: 'Click the verification link in the email.',
        ),
        SizedBox(height: 8),
        _ChecklistItem(
          icon: Icons.phone_iphone,
          text: 'Return to the app to continue.',
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
