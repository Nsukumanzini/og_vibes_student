import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VibeScaffold extends StatelessWidget {
  const VibeScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LAYER 1: Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F7FA), Color(0xFFE3F2FD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // LAYER 2: Decorative blobs
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: const Color(0xFF2962FF).withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: const Color(0xFF00E5FF).withOpacity(0.1),
            ),
          ),
        ),
        // LAYER 3: Main content
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark, // Dark icons for status bar
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            drawer: drawer,
            body: SafeArea(child: body),
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ),
      ],
    );
  }
}
