// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/services/attachment_service.dart';
import '../../domain/models/attachment_file.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatMessagesUpdated extends ChatState {
  final List<ChatMessage> messages;
  ChatMessagesUpdated(this.messages);
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final AttachmentService _attachmentService;

  ChatCubit({
    required ChatRepository chatRepository,
    required AttachmentService attachmentService,
  })  : _chatRepository = chatRepository,
        _attachmentService = attachmentService,
        super(ChatInitial());

  StreamSubscription? _messagesSubscription;
  List<AttachmentFile> _attachments = [];
  ChatMessage? _replyToMessage;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessages = {};

  List<AttachmentFile> get attachments => _attachments;
  ChatMessage? get replyToMessage => _replyToMessage;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedMessages => _selectedMessages;
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  void initialize(String chatId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository
        .getMessages(chatId)
        .listen(_handleMessagesUpdate)
      ..onError(_handleError);
  }

  void _handleMessagesUpdate(QuerySnapshot snapshot) {
    try {
      final messages =
          snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
      emit(ChatMessagesUpdated(messages));
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    emit(ChatError(error.toString()));
  }

  Future<void> sendMessage(
      String chatId, String text, String? supplierId) async {
    try {
      await _chatRepository.sendTextMessage(
        chatId: chatId,
        text: text,
        replyToId: _replyToMessage?.id,
        supplierId: supplierId,
      );
      clearReplyMessage();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> sendAttachment(
    String chatId,
    AttachmentFile attachment,
    String? supplierId,
  ) async {
    try {
      await _chatRepository.sendAttachment(
        chatId: chatId,
        attachment: attachment,
        replyToId: _replyToMessage?.id,
        supplierId: supplierId,
        onProgress: (progress) {
          // Handle upload progress
        },
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> pickImages() async {
    try {
      final images = await _attachmentService.pickImages();
      _attachments.addAll(images);
      emit(ChatMessagesUpdated([])); // Trigger UI update
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> pickFiles() async {
    try {
      final files = await _attachmentService.pickFiles();
      _attachments.addAll(files);
      emit(ChatMessagesUpdated([])); // Trigger UI update
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> captureImage() async {
    try {
      final image = await _attachmentService.captureImage();
      if (image != null) {
        _attachments.add(image);
        emit(ChatMessagesUpdated([])); // Trigger UI update
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void removeAttachment(int index) {
    _attachments.removeAt(index);
    emit(ChatMessagesUpdated([])); // Trigger UI update
  }

  void setReplyMessage(ChatMessage message) {
    _replyToMessage = message;
    emit(ChatMessagesUpdated([])); // Trigger UI update
  }

  void clearReplyMessage() {
    _replyToMessage = null;
    emit(ChatMessagesUpdated([])); // Trigger UI update
  }

  void clearSelection() {
    _selectedMessages.clear();
    _isSelectionMode = false;
    emit(ChatMessagesUpdated([])); // Trigger UI update
  }

  void copySelectedMessages() {
    // Implement copy functionality if needed
  }

  void toggleMessageSelection(String messageId) {
    if (_selectedMessages.contains(messageId)) {
      _selectedMessages.remove(messageId);
      if (_selectedMessages.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedMessages.add(messageId);
      _isSelectionMode = true;
    }
    emit(ChatMessagesUpdated([])); // Trigger UI update
  }

  Future<void> deleteSelectedMessages(String chatId) async {
    try {
      await _chatRepository.deleteMessages(chatId, _selectedMessages.toList());
      _selectedMessages.clear();
      _isSelectionMode = false;
      emit(ChatMessagesUpdated([])); // Trigger UI update
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _chatRepository.deleteMessage(chatId, messageId);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> clearChat(String chatId) async {
    try {
      await _chatRepository.clearChat(chatId);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
