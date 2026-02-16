import 'package:flutter/material.dart';

class PostFab extends StatelessWidget {
  const PostFab({
    super.key,
    required this.isFabVisible,
    required this.onPressed,
  });

  final bool isFabVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      scale: isFabVisible ? 1.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 10,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Post Vibe'),
        ),
      ),
    );
  }
}
