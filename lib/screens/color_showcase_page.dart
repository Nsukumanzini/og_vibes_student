import 'package:flutter/material.dart';

class ColorShowcasePage extends StatelessWidget {
  const ColorShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('OG Vibes Color Showcase'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ColorTile(
            color: theme.colorScheme.primary,
            label: 'Primary Blue',
            textColor: Colors.white,
          ),
          _ColorTile(
            color: theme.colorScheme.secondary,
            label: 'Accent Cyan',
            textColor: Colors.black,
          ),
          _ColorTile(
            color: const Color(0xFF0D47A1),
            label: 'Navy Text',
            textColor: Colors.white,
          ),
          _ColorTile(
            color: theme.scaffoldBackgroundColor,
            label: 'Scaffold Background',
            textColor: Colors.black,
          ),
          _ColorTile(
            color: Colors.white,
            label: 'White Surface',
            textColor: Colors.black,
          ),
          _ColorTile(
            color: Colors.grey[50]!,
            label: 'Input Field Background',
            textColor: Colors.black,
          ),
          _ColorTile(
            color: const Color(0xFFFFD740),
            label: 'Highlight Yellow',
            textColor: Colors.black,
          ),
          const SizedBox(height: 32),
          Text('Sample Buttons', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: const Text('Primary Button')),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.black,
            ),
            onPressed: () {},
            child: const Text('Accent Button'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD740),
              foregroundColor: Colors.black,
            ),
            onPressed: () {},
            child: const Text('Highlight Button'),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;
  const _ColorTile({
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
