class LiveSession {
  const LiveSession({
    required this.subject,
    required this.topic,
    required this.time,
    required this.isLive,
    required this.lecturer,
  });

  final String subject;
  final String topic;
  final String time;
  final bool isLive;
  final String lecturer;
}
