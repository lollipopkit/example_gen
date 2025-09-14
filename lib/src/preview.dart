library;

import 'dart:convert';

class PreviewNode {
  final String name;
  final String type; // e.g. string/int/double/bool/object/array/enum/DateTime
  final bool nullable;
  final String? example;
  final String? description;
  final Map<String, Object?>? constraints;
  final List<PreviewNode> children;

  PreviewNode({
    required this.name,
    required this.type,
    this.nullable = false,
    this.example,
    this.description,
    this.constraints,
    this.children = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'nullable': nullable,
        'example': example,
        'description': description,
        'constraints': constraints,
        'children': children.map((e) => e.toJson()).toList(),
      };
}

/// Convert JSON Map to structure preview JSON string (for UI tree rendering)
/// This does not contain annotation info (that part is better handled by generated code injecting constraints when building example JSON)
String toPreviewJson(Map<String, dynamic> json, {String rootName = 'root'}) {
  PreviewNode build(String name, dynamic v) {
    if (v is Map<String, dynamic>) {
      return PreviewNode(
        name: name,
        type: 'object',
        children: v.entries.map((e) => build(e.key, e.value)).toList(),
      );
    } else if (v is List) {
      return PreviewNode(
        name: name,
        type: 'array',
        children: v.isNotEmpty ? [build('[0]', v.first)] : const [],
      );
    } else if (v is String) {
      return PreviewNode(name: name, type: 'string', example: v);
    } else if (v is int) {
      return PreviewNode(name: name, type: 'int', example: '$v');
    } else if (v is double) {
      return PreviewNode(name: name, type: 'double', example: '$v');
    } else if (v is bool) {
      return PreviewNode(name: name, type: 'bool', example: '$v');
    } else if (v == null) {
      return PreviewNode(name: name, type: 'null', example: 'null', nullable: true);
    } else {
      return PreviewNode(name: name, type: v.runtimeType.toString());
    }
  }

  final node = build(rootName, json);
  return const JsonEncoder.withIndent('  ').convert(node.toJson());
}