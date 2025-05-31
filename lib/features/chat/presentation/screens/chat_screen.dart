import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/chat_textfield.dart';
import '../widgets/message_list.dart';
import '../../domain/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String? supplierId;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.supplierId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;
  Map<String, dynamic>? supplier;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    context.read<ChatCubit>().initialize(widget.chatId);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final cubit = context.read<ChatCubit>();

        return Scaffold(
          appBar: _buildAppBar(context, cubit),
          body: Column(
            children: [
              if (_isSearchMode) _buildSearchBar(),
              if (cubit.replyToMessage != null)
                _buildReplyPreview(cubit.replyToMessage!),
              Expanded(
                child: MessageList(
                  messages: state is ChatMessagesUpdated ? state.messages : [],
                  selectedMessages: cubit.selectedMessages,
                  isSelectionMode: cubit.isSelectionMode,
                  onMessageSelected: (messageId) =>
                      cubit.toggleMessageSelection(messageId),
                  onMessageTap: _showMessageOptions,
                ),
              ),
              EnhancedChatTextfield(
                chatId: widget.chatId,
                supplierId: widget.supplierId,
                replyToMessage: cubit.replyToMessage,
                onClearReply: () => cubit.clearReplyMessage(),
                attachments: cubit.attachments,
                onAttachmentRemoved: cubit.removeAttachment,
                onSendMessage: (text) =>
                    cubit.sendMessage(widget.chatId, text, widget.supplierId),
                onPickImages: cubit.pickImages,
                onPickFiles: cubit.pickFiles,
                onCaptureImage: cubit.captureImage,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatCubit cubit) {
    if (cubit.isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            cubit.clearSelection();
          },
        ),
        title: Text(
          '${cubit.selectedMessages.length} محدد',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () => cubit.copySelectedMessages(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => cubit.deleteSelectedMessages(widget.chatId),
          ),
        ],
      );
    }

    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(supplier?['profileImage'] ?? ''),
            child: supplier?['profileImage'] == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(supplier?['name'] ?? 'المورد'),
              Text(
                'متصل',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() => _isSearchMode = true);
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'بحث في المحادثة...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearchMode = false;
                _searchController.clear();
              });
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // Implement search logic
        },
      ),
    );
  }

  Widget _buildReplyPreview(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرد على:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  message.text ?? '[مرفق]',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              context.read<ChatCubit>().clearReplyMessage();
            },
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.senderId == context.read<ChatCubit>().currentUserId)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('حذف الرسالة'),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ChatCubit>()
                      .deleteMessage(widget.chatId, message.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('رد'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatCubit>().setReplyMessage(message);
              },
            ),
            if (message.text != null)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message.text!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ النص')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('مسح المحادثة'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatCubit>().clearChat(widget.chatId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('حظر'),
              onTap: () {
                Navigator.pop(context);
                // Implement block logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
