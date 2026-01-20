import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_study_helper/widgets/message_bubble.dart';
import 'package:ai_study_helper/models/message_model.dart';
import 'package:ai_study_helper/services/conversation_service.dart';
import 'package:ai_study_helper/services/auth_service.dart';
import 'package:ai_study_helper/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversationService = ConversationService();
      final messages = await conversationService.getConversationMessages(widget.conversationId);
      
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        
        // 滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Load messages failed: $e');
      // 临时使用假数据
      if (mounted) {
        setState(() {
          _messages = [
            Message(
              messageId: '1',
              conversationId: widget.conversationId,
              role: 'user',
              content: 'Can you explain the difference between past simple and present perfect?',
              tokensUsed: 10,
              createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
            Message(
              messageId: '2',
              conversationId: widget.conversationId,
              role: 'assistant',
              content: 'Certainly! The **Past Simple** is used for actions that happened at a specific time in the past and are finished.\n\nExample: *I visited Paris last year.*\n\nThe **Present Perfect** is used for actions that happened at an unspecified time in the past or have a connection to the present.\n\nExample: *I have visited Paris twice.* (and I might go again)',
              tokensUsed: 50,
              createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
            ),
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    final userMessage = Message(
      messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      role: 'user',
      content: text,
      tokensUsed: 0,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _textController.clear();
      _isSending = true;
    });

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final conversationService = ConversationService();
      final response = await conversationService.sendMessage(widget.conversationId, text);

      if (mounted) {
        setState(() {
          _messages.removeLast(); // 移除临时消息
          if (response != null) {
            _messages.add(response);
          }
          _isSending = false;
        });

        // 滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeLast(); // 移除临时消息
          _isSending = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送消息失败: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _generateMindMap() async {
    try {
      final authService = AuthService();
      final token = await authService.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final apiService = ApiService();
      final response = await apiService.generateMindMap(token, widget.conversationId);
      
      if (mounted && response.isSuccess && response.data != null) {
        context.push('/home/mindmap/${response.data!.mindmapId}');
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成思维导图失败: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习对话'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high_outlined),
            tooltip: '生成思维导图',
            onPressed: _isLoading ? null : _generateMindMap,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败: $_error',
              style: TextStyle(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadMessages,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '还没有消息\n开始第一轮对话吧！',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageBubble(
          message: message,
          isUser: message.role == 'user',
        );
      },
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              enabled: !_isSending,
              decoration: InputDecoration(
                hintText: '输入你的问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isSending ? null : _sendMessage,
            mini: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: _isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
