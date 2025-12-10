import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsRef = FirebaseFirestore.instance
        .collection('events')
        .orderBy('date', descending: false);

    return VibeScaffold(
      appBar: AppBar(title: const Text('Events & Parties')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: eventsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!.docs;
          if (events.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No events on the calendar yet. Host something epic and tell us!',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = events[index].data();
              final title = (data['title'] as String?) ?? 'Campus Event';
              final date = (data['dateLabel'] as String?) ?? 'Date TBA';
              final venue = (data['venue'] as String?) ?? 'Venue TBA';
              final price = (data['price'] as String?) ?? 'Free';
              final image = data['imageUrl'] as String?;
              final whatsapp = (data['contact'] as String?)?.trim();
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image != null && image.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          image,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 180,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Text('Image unavailable'),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Date: $date'),
                          Text('Venue: $venue'),
                          Text('Damage: $price'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: whatsapp == null
                                  ? null
                                  : () => _openWhatsapp(whatsapp, title),
                              child: const Text('Buy Ticket'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openWhatsapp(String phone, String eventName) async {
    final encoded = Uri.encodeComponent('I want a ticket for $eventName');
    final uri = Uri.parse('https://wa.me/$phone?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
