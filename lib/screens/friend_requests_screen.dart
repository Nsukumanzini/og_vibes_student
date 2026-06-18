import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;
  final List<Map<String, dynamic>> _incoming = [];

  @override
  void initState() {
    super.initState();
    _requestsFuture = _loadRequests();
  }

  Future<List<Map<String, dynamic>>> _loadRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    const initial = [
      {'name': 'David S.', 'course': 'Civil Engineering'},
      {'name': 'Nomsa', 'course': 'Hospitality'},
    ];

    _incoming
      ..clear()
      ..addAll(initial);

    return initial;
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildShimmerState();
          }

          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _requestsFuture = _loadRequests();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry requests load'),
              ),
            );
          }

          if (_incoming.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: _incoming.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final request = _incoming[index];
              return _RequestCard(
                request: request,
                onAccept: () => _handleAccept(request),
                onDecline: () => _handleDecline(request),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, _) => Container(
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.group_outlined, size: 54, color: Colors.black38),
          SizedBox(height: 10),
          Text(
            'No pending friend requests.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _handleAccept(Map<String, dynamic> request) {
    final name = request['name'] as String;
    setState(() => _incoming.remove(request));
    final firstName = name.split(' ').first;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are now connected with $firstName!')),
    );
  }

  void _handleDecline(Map<String, dynamic> request) {
    final name = request['name'] as String;
    setState(() => _incoming.remove(request));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Declined request from $name.')),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final name = request['name'] as String;
    final course = request['course'] as String;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2962FF).withValues(alpha: 0.12),
            child: const Icon(Icons.person, color: Color(0xFF2962FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Decline'),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
