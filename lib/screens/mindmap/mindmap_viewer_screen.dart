import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ai_study_helper/models/mindmap_node.dart';
import 'package:ai_study_helper/services/api_service.dart';
import 'package:ai_study_helper/services/auth_service.dart';

class MindMapViewScreen extends StatefulWidget {
  final String mindmapId;

  const MindMapViewScreen({
    super.key,
    required this.mindmapId,
  });

  @override
  State<MindMapViewScreen> createState() => _MindMapViewScreenState();
}

class _MindMapViewScreenState extends State<MindMapViewScreen> with TickerProviderStateMixin {
  MindMapNode? _rootNode;
  bool _isLoading = true;
  String? _error;
  
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _dragStart = Offset.zero;
  double _initialScale = 1.0;
  bool _isDragging = false;

  // 动画控制器
  late Map<String, AnimationController> _nodeControllers;
  late Map<String, Animation<double>> _nodeAnimations;

  @override
  void initState() {
    super.initState();
    _nodeControllers = {};
    _nodeAnimations = {};
    _loadMindMap();
  }

  @override
  void dispose() {
    for (final controller in _nodeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMindMap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = AuthService();
      final token = await authService.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final apiService = ApiService();
      final response = await apiService.getMindMap(token, widget.mindmapId);
      
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            _rootNode = response.data!.rootNode;
            _isLoading = false;
          });
          
          // 初始化节点动画
          _initNodeAnimations(_rootNode!);
        } else {
          setState(() {
            _error = response.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _initNodeAnimations(MindMapNode node) {
    // 为当前节点创建动画控制器
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _nodeControllers[node.id] = controller;
    _nodeAnimations[node.id] = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    
    // 启动动画
    controller.forward();

    // 递归初始化子节点
    for (final child in node.children) {
      _initNodeAnimations(child);
    }
  }

  void _toggleNodeExpansion(MindMapNode node) {
    setState(() {
      node.isExpanded = !node.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('思维导图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _isLoading ? null : _loadMindMap,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: '放大',
            onPressed: () {
              setState(() {
                _scale = (_scale * 1.2).clamp(0.5, 3.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: '缩小',
            onPressed: () {
              setState(() {
                _scale = (_scale / 1.2).clamp(0.5, 3.0);
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          : _error != null
              ? Center(
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
                        onPressed: _loadMindMap,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _rootNode == null
                  ? Center(
                      child: Text(
                        '思维导图为空',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : InteractiveViewer(
                      scaleEnabled: true,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: CustomPaint(
                        painter: MindMapPainter(
                          rootNode: _rootNode!,
                          nodeControllers: _nodeControllers,
                          nodeAnimations: _nodeAnimations,
                          onNodeTap: _toggleNodeExpansion,
                          colorScheme: colorScheme,
                        ),
                        size: Size.infinite,
                      ),
                    ),
    );
  }
}

class MindMapPainter extends CustomPainter {
  final MindMapNode rootNode;
  final Map<String, AnimationController> nodeControllers;
  final Map<String, Animation<double>> nodeAnimations;
  final Function(MindMapNode) onNodeTap;
  final ColorScheme colorScheme;

  MindMapPainter({
    required this.rootNode,
    required this.nodeControllers,
    required this.nodeAnimations,
    required this.onNodeTap,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _drawNode(canvas, rootNode, center, size, 0);
  }

  void _drawNode(Canvas canvas, MindMapNode node, Offset position, Size size, int depth) {
    final animation = nodeAnimations[node.id];
    final scale = animation?.value ?? 1.0;

    // 绘制连接线（如果是子节点）
    if (node.parentId != null) {
      final parentPosition = _getNodePosition(node.parentId!, size);
      final paint = Paint()
        ..color = colorScheme.onSurfaceVariant.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(parentPosition, position, paint);
    }

    // 绘制节点
    final nodePaint = Paint()
      ..color = _getNodeColor(depth)
      ..style = PaintingStyle.fill;
    
    final textPaint = TextPainter(
      text: TextSpan(
        text: node.text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14 - (depth * 1.5).clamp(0.0, 4.0),
          fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPaint.layout();

    final nodeSize = Size(
      (textPaint.width + 32).clamp(60.0, 200.0),
      (textPaint.height + 16).clamp(40.0, 100.0),
    );

    final rect = Rect.fromCenter(
      center: position,
      width: nodeSize.width * scale,
      height: nodeSize.height * scale,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(12 * scale)),
      nodePaint,
    );

    // 绘制文本
    textPaint.paint(
      canvas,
      Offset(
        position.dx - textPaint.width / 2,
        position.dy - textPaint.height / 2,
      ),
    );

    // 递归绘制子节点
    if (node.isExpanded) {
      for (int i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        final childPosition = _getChildPosition(position, i, node.children.length, depth);
        _drawNode(canvas, child, childPosition, size, depth + 1);
      }
    }
  }

  Offset _getNodePosition(String nodeId, Size size) {
    // 简化实现：返回根节点位置
    return Offset(size.width / 2, size.height / 2);
  }

  Offset _getChildPosition(Offset parentPos, int index, int total, int depth) {
    // 计算子节点的位置，围绕父节点分布
    final angleStep = (2 * 3.14159) / total;
    final radius = 150.0 + (depth * 80.0);
    final angle = angleStep * index;

    return Offset(
      parentPos.dx + radius * math.cos(angle),
      parentPos.dy + radius * math.sin(angle),
    );
  }

  Color _getNodeColor(int depth) {
    // 使用主题色彩系统
    switch (depth) {
      case 0:
        return colorScheme.primary;
      case 1:
        return colorScheme.secondary;
      case 2:
        return colorScheme.tertiary;
      default:
        return colorScheme.primaryContainer;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
