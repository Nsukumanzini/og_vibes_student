import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.type,
    required this.status,
    this.messageId,
    this.audioDuration = '0:15',
    this.onReply,
  });

  final String message;
  final bool isMe;
  final String type; // text | audio
  final String status; // sent | delivered | read
  final String? messageId;
  final String audioDuration;
  final void Function(String message)? onReply;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  double _audioProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final alignment = widget.isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final background = widget.isMe
        ? const Color(0xFF2962FF)
        : const Color(0xFFE0E0E0);
    final textColor = widget.isMe ? Colors.white : Colors.black87;

    return Dismissible(
      key: ValueKey(widget.messageId ?? widget.message.hashCode),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async => false,
      onDismissed: (_) => widget.onReply?.call(widget.message),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: Colors.white24,
        child: const Icon(Icons.reply, color: Colors.white70),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(widget.isMe ? 18 : 6),
                    bottomRight: Radius.circular(widget.isMe ? 6 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildContent(textColor),
                    if (widget.isMe) const SizedBox(height: 18),
                  ],
                ),
              ),
              if (widget.isMe)
                Positioned(right: 10, bottom: 6, child: _buildReadReceipt()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (widget.type == 'audio') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: textColor),
            color: textColor,
            onPressed: () {
              setState(() => _audioProgress = 0.0);
            },
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
                trackHeight: 2.5,
              ),
              child: Slider(
                min: 0,
                max: 1,
                value: _audioProgress,
                activeColor: textColor,
                inactiveColor: textColor.withValues(alpha: 0.25),
                onChanged: (value) {
                  setState(() => _audioProgress = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.audioDuration,
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        ],
      );
    }

    return Text(
      widget.message,
      style: TextStyle(color: textColor, fontSize: 15),
    );
  }

  Widget _buildReadReceipt() {
    final status = widget.status.toLowerCase();
    const grey = Color(0xFFB0BEC5);
    const blue = Color(0xFF40C4FF);

    if (status == 'sent') {
      return const Icon(Icons.check, size: 14, color: grey);
    }

    final color = status == 'read' ? blue : grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, size: 14, color: color),
        const SizedBox(width: 2),
        Icon(Icons.check, size: 14, color: color),
      ],
    );
  }
}
