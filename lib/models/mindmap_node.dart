class MindMapNode {
  final String id;
  final String text;
  final List<MindMapNode> children;
  String? parentId;
  bool isExpanded = true;

  MindMapNode({
    required this.id,
    required this.text,
    required this.children,
    this.parentId,
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] as String,
      text: json['text'] as String,
      children: (json['children'] as List?)
              ?.map((child) => MindMapNode.fromJson(child as Map<String, dynamic>)..parentId = json['id'] as String)
              .toList() ??
          [],
      parentId: json['parent_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'children': children.map((child) => child.toJson()).toList(),
      if (parentId != null) 'parent_id': parentId,
    };
  }

  MindMapNode copyWith({
    String? id,
    String? text,
    List<MindMapNode>? children,
    String? parentId,
    bool? isExpanded,
  }) {
    return MindMapNode(
      id: id ?? this.id,
      text: text ?? this.text,
      children: children ?? this.children,
      parentId: parentId ?? this.parentId,
    )..isExpanded = isExpanded ?? this.isExpanded;
  }
}
