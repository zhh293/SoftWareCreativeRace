import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ai_study_helper/providers/app_state_provider.dart';
import 'package:ai_study_helper/widgets/conversation_list_tile.dart';
import 'package:ai_study_helper/models/conversation_model.dart';
import 'package:ai_study_helper/services/conversation_service.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversationService = ConversationService();
      final conversations = await conversationService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load conversations failed: $e');
      // 临时使用假数据展示 UI 效果
      if (mounted) {
        setState(() {
          _conversations = [
            Conversation(
              conversationId: '1',
              title: '英语语法学习',
              modelId: 'gpt4o',
              presetId: 'explain_like_friend',
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              updatedAt: DateTime.now(),
              messageCount: 12,
              lastMessageSummary:
                  'Explain the difference between past simple and present perfect.',
            ),
            Conversation(
              conversationId: '2',
              title: '微积分辅导',
              modelId: 'deepthinker',
              presetId: 'exam_step_by_step',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              updatedAt: DateTime.now().subtract(const Duration(days: 1)),
              messageCount: 5,
              lastMessageSummary:
                  'How to calculate the derivative of sin(x^2)?',
            ),
            Conversation(
              conversationId: '3',
              title: 'Python 基础入门',
              modelId: 'gpt4o',
              presetId: 'explain_like_friend',
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
              updatedAt: DateTime.now().subtract(const Duration(days: 2)),
              messageCount: 8,
              lastMessageSummary: 'What is a list comprehension?',
            ),
          ];
          _isLoading = false;
          // _error = e.toString().replaceAll('Exception: ', ''); // 不显示错误，只显示假数据
        });
      }
    }
  }

  Future<void> _createNewConversation() async {
    try {
      final conversationService = ConversationService();
      final conversation = await conversationService.createConversation(
        title: '新学习会话',
        modelId: 'gpt4o',
        presetId: 'explain_like_friend',
      );

      if (mounted && conversation != null) {
        context.push('/home/chat/${conversation.conversationId}');
      }
    } catch (e) {
      debugPrint('Create conversation failed: $e');
      // 临时跳转到演示会话
      if (mounted) {
        context.push('/home/chat/new_demo_chat');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userNickname = context.select<AppStateProvider, String?>(
          (provider) => provider.nickname,
        ) ??
        '同学';

    return Scaffold(
      appBar: AppBar(
        title: Text('欢迎回来，$userNickname'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 设置页面待实现
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        color: colorScheme.primary,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '开始学习',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '选择一个学习场景开始对话',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildRecentConversations(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewConversation,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text('新建学习对话'),
          ],
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionCard(
            icon: Icons.school_outlined,
            title: '课堂辅导',
            onTap: () =>
                _startNewConversation('课堂辅导', 'gpt4o', 'explain_like_friend'),
          ),
          const SizedBox(width: 12),
          _buildQuickActionCard(
            icon: Icons.calculate_outlined,
            title: '解题助手',
            onTap: () => _startNewConversation(
                '解题助手', 'deepthinker', 'exam_step_by_step'),
          ),
          const SizedBox(width: 12),
          _buildQuickActionCard(
            icon: Icons.code_outlined,
            title: '编程学习',
            onTap: () =>
                _startNewConversation('编程学习', 'gpt4o', 'explain_like_friend'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentConversations() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近会话',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_conversations.isNotEmpty)
                TextButton(
                  onPressed: _loadConversations,
                  child: const Text('刷新'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          else if (_error != null)
            Center(
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
                    onPressed: _loadConversations,
                    child: const Text('重试'),
                  ),
                ],
              ),
            )
          else if (_conversations.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
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
                    '还没有学习记录\n点击右下角按钮开始第一个对话',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _conversations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return ConversationListTile(
                    conversation: conversation,
                    onTap: () {
                      debugPrint(
                          'Tapped conversation: ${conversation.conversationId}');
                      context.pushNamed(
                        'chat',
                        pathParameters: {
                          'conversationId': conversation.conversationId
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _startNewConversation(
      String title, String modelId, String presetId) async {
    try {
      final conversationService = ConversationService();
      final conversation = await conversationService.createConversation(
        title: title,
        modelId: modelId,
        presetId: presetId,
      );

      if (mounted && conversation != null) {
        context.push('/home/chat/${conversation.conversationId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('创建会话失败: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
