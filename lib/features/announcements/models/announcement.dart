class Announcement {
  final String id;
  final String schoolId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool priority;
  final bool isDeleted;

  Announcement({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.priority,
    required this.isDeleted,
  });

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'urgent' || s == 'priority';
    }
    return false;
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: (json['id'] ?? '').toString(),
      schoolId: (json['school_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      priority: _parseBool(json['priority']),
      isDeleted: _parseBool(json['is_deleted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'priority': priority ? 'true' : 'false',
      'is_deleted': isDeleted,
    };
  }

  /// Extracts target recipient badge if specified in the content header
  String? get targetTag {
    if (content.startsWith('📌 موجه إلى: ')) {
      final endIdx = content.indexOf('\n\n');
      if (endIdx != -1) {
        return content.substring('📌 موجه إلى: '.length, endIdx).trim();
      }
      final lineEnd = content.indexOf('\n');
      if (lineEnd != -1) {
        return content.substring('📌 موجه إلى: '.length, lineEnd).trim();
      }
      return content.substring('📌 موجه إلى: '.length).trim();
    }
    return null;
  }

  /// Returns clean announcement text without internal target prefix
  String get cleanContent {
    if (content.startsWith('📌 موجه إلى: ')) {
      final endIdx = content.indexOf('\n\n');
      if (endIdx != -1) {
        return content.substring(endIdx + 2).trim();
      }
      final lineEnd = content.indexOf('\n');
      if (lineEnd != -1) {
        return content.substring(lineEnd + 1).trim();
      }
    }
    return content;
  }
}
