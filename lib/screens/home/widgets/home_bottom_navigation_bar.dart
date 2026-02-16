import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Theme.of(context).primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dynamic_feed_outlined),
          label: 'Feed',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_customize_outlined),
          label: 'Hub',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.secondary),
          activeIcon: Icon(
            Icons.notifications_active,
            color: Theme.of(context).colorScheme.secondary,
          ),
          label: 'Alerts',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: 'Study',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
      ],
    );
  }
}