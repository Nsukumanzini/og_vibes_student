import 'package:flutter/material.dart';

class MyCampusFriendsScreen extends StatelessWidget {
  const MyCampusFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Campus Friends')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text(
              'No friends yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Connect with students and see your friends here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
