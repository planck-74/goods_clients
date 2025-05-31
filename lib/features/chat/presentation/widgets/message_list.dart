import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/chat_message.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final Set<String> selectedMessages;
  final bool isSelectionMode;
  final Function(String) onMessageSelected;
  final Function(ChatMessage) onMessageTap;
  final ScrollController? scrollController;

  const MessageList({
    super.key,
    required this.messages,
    required this.selectedMessages,
    required this.isSelectionMode,
    required this.onMessageSelected,
    required this.onMessageTap,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSelected = selectedMessages.contains(message.id);

        // Check if we need to show a date header
        bool showDateHeader = false;
        if (index == messages.length - 1) {
          showDateHeader = true;
        } else {
          final currentDate =
              DateFormat('yyyy-MM-dd').format(message.timestamp);
          final previousDate =
              DateFormat('yyyy-MM-dd').format(messages[index + 1].timestamp);
          showDateHeader = currentDate != previousDate;
        }

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.timestamp),
            MessageBubble(
              message: message,
              isSelected: isSelected,
              isSelectionMode: isSelectionMode,
              onLongPress: () => onMessageSelected(message.id),
              onTap: isSelectionMode
                  ? () => onMessageSelected(message.id)
                  : () => onMessageTap(message),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            DateFormat('EEEE, d MMMM y', 'ar').format(date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
