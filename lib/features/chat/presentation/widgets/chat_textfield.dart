import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/attachment_file.dart';

class EnhancedChatTextfield extends StatefulWidget {
  final String chatId;
  final String? supplierId;
  final ChatMessage? replyToMessage;
  final VoidCallback? onClearReply;
  final List<AttachmentFile> attachments;
  final Function(String) onSendMessage;
  final Function(int) onAttachmentRemoved;
  final VoidCallback onPickImages;
  final VoidCallback onPickFiles;
  final VoidCallback onCaptureImage;
  const EnhancedChatTextfield({
    super.key,
    required this.chatId,
    required this.supplierId,
    this.replyToMessage,
    this.onClearReply,
    required this.attachments,
    required this.onSendMessage,
    required this.onAttachmentRemoved,
    required this.onPickImages,
    required this.onPickFiles,
    required this.onCaptureImage,
  });

  @override
  State<EnhancedChatTextfield> createState() => _EnhancedChatTextfieldState();
}

class _EnhancedChatTextfieldState extends State<EnhancedChatTextfield>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  // Animation controllers
  late AnimationController _sendButtonController;
  late AnimationController _attachmentController;
  late Animation<double> _sendButtonAnimation;
  late Animation<double> _attachmentAnimation;

  // Typing state
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
  }

  void _setupControllers() {
    _messageController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _setupAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _attachmentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sendButtonAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.elasticOut),
    );
    _attachmentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _attachmentController, curve: Curves.easeInOut),
    );
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText && !_sendButtonController.isCompleted) {
      _sendButtonController.forward();
    } else if (!hasText && !_sendButtonController.isDismissed) {
      _sendButtonController.reverse();
    }

    if (hasText && !_isTyping) {
      setState(() => _isTyping = true);
      _sendTypingIndicator();
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _attachmentController.forward();
    } else {
      _attachmentController.reverse();
    }
  }

  Future<void> _sendTypingIndicator() async {
    // Implement typing indicator logic here
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && widget.attachments.isEmpty) return;
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      if (text.isNotEmpty) {
        await widget.onSendMessage(text);
      }
      _messageController.clear();
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onCaptureImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'المعرض',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPickImages();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.attach_file,
                  label: 'ملف',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onPickFiles();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.attachments.length,
        itemBuilder: (context, index) {
          final attachment = widget.attachments[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                if (attachment.type == AttachmentType.image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(attachment.path),
                      fit: BoxFit.cover,
                      width: 80,
                      height: 100,
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.insert_drive_file,
                      size: 32,
                      color: Colors.grey[600],
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => widget.onAttachmentRemoved(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            if (widget.attachments.isNotEmpty) _buildAttachmentPreview(),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _attachmentAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _attachmentAnimation.value,
                    child: IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _showAttachmentOptions,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _sendButtonAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _sendButtonAnimation.value,
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    _attachmentController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}
