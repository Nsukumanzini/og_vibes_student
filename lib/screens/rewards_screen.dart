import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/services/ad_service.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  static const _darkWhite = Color(0xFFE0E0E0);
  final Map<String, int> _rewardOptions = {
    'MTN Airtime R10': 200,
    'HollywoodBets R50': 600,
    'Data Bundle': 350,
  };

  String _selectedReward = 'MTN Airtime R10';
  bool _loadingAd = false;
  bool _requesting = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return VibeScaffold(
        appBar: AppBar(title: const Text('Vibe Rewards')),
        body: const Center(
          child: Text(
            'Sign in to collect vibe points.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return VibeScaffold(
      appBar: AppBar(title: const Text('Vibe Rewards')),
      body: Theme(
        data: theme.copyWith(textTheme: textTheme),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final points = (snapshot.data!.data()?['points'] as int?) ?? 0;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Vibe Points',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          points.toString(),
                          style: const TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD740),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          points < 100
                              ? 'Watch more videos to unlock rewards.'
                              : 'Ready to redeem something tasty.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: _buttonStyle(),
                      onPressed: _loadingAd
                          ? null
                          : () => _watchRewardedAd(user.uid),
                      icon: _loadingAd
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.play_circle_outline,
                              color: Colors.black,
                            ),
                      label: const Text(
                        'Watch Video (+50 Points)',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Redeem Voucher',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedReward,
                    decoration: _dropdownDecoration('Choose reward'),
                    dropdownColor: _darkWhite,
                    style: const TextStyle(color: Colors.black87),
                    items: _rewardOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              '${entry.key} (${entry.value} pts)',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedReward = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: _buttonStyle(),
                      onPressed: _requesting
                          ? null
                          : () => _requestRedemption(user.uid, points),
                      child: Text(
                        _requesting ? 'Requesting...' : 'Request',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _darkWhite,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _darkWhite,
      labelStyle: const TextStyle(color: Colors.black87),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _watchRewardedAd(String uid) async {
    setState(() => _loadingAd = true);
    try {
      final shown = await AdHelper.loadRewardedAd(
        onReward: () => _handleRewardEarned(uid),
      );

      if (!shown && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No ad available right now.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingAd = false);
      }
    }
  }

  void _handleRewardEarned(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'points': FieldValue.increment(50)})
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('+50 points added!')));
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update points: $error')),
            );
          }
        });
  }

  Future<void> _requestRedemption(String uid, int points) async {
    final cost = _rewardOptions[_selectedReward] ?? 0;
    if (points < cost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not enough points yet.')));
      return;
    }

    setState(() => _requesting = true);
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final redemptionRef = FirebaseFirestore.instance
        .collection('redemptions')
        .doc();
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        final current = (snapshot.data()?['points'] as int?) ?? 0;
        if (current < cost) {
          throw Exception('Insufficient points');
        }
        transaction.update(userRef, {'points': current - cost});
        transaction.set(redemptionRef, {
          'reward': _selectedReward,
          'cost': cost,
          'status': 'requested',
          'userId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your inbox in 24h!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }
}
