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
    final background = widget.isMe ? const Color(0xFF2962FF) : Colors.white;
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
                  boxShadow: widget.isMe
                      ? []
                      : [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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

  Widget _buildReadReceipt() {
    IconData icon;
    Color color;

    switch (widget.status) {
      case 'read':
        icon = Icons.done_all;
        color = Colors.blueAccent;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case 'sent':
      default:
        icon = Icons.done;
        color = Colors.grey;
        break;
    }

    return Icon(icon, size: 18, color: color);
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
              ),
              child: Slider(
                value: _audioProgress,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() => _audioProgress = value);
                },
                activeColor: textColor,
                // ignore: deprecated_member_use
                inactiveColor: textColor.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.audioDuration,
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
      );
    }
    // Handle text message
    return Text(
      widget.message,
      style: TextStyle(color: textColor, fontSize: 16),
    );
  }
}
