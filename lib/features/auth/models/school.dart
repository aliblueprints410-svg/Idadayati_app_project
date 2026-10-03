class School {
  final String id;
  final String name;
  final String schoolCode;
  final String schoolType; // 'vocational', 'academic', 'middle', 'primary'
  final String stage;

  const School({
    required this.id,
    required this.name,
    required this.schoolCode,
    this.schoolType = 'middle',
    this.stage = 'middle',
  });

  bool get isVocational =>
      schoolType.toLowerCase() == 'vocational' ||
      stage.toLowerCase() == 'vocational' ||
      name.contains('مهن') ||
      name.contains('صناع');

  bool get isAcademic =>
      schoolType.toLowerCase() == 'academic' ||
      stage.toLowerCase() == 'academic' ||
      (!isVocational && (name.contains('إعداد') || name.contains('اعداد') || name.contains('متميز')));

  bool get isMiddle =>
      schoolType.toLowerCase() == 'middle' ||
      stage.toLowerCase() == 'middle' ||
      name.contains('متوسط');

  bool get isPrimary =>
      schoolType.toLowerCase() == 'primary' ||
      stage.toLowerCase() == 'primary' ||
      name.contains('ابتدائ');

  String get typeLabel {
    if (isVocational) return '⚙️ إعدادية مهنية تخصصية';
    if (isAcademic) return '🔬 إعدادية أكاديمية (علمي / أدبي)';
    if (isMiddle) return '📘 مدرسة متوسطة';
    if (isPrimary) return '🌱 مدرسة ابتدائية';
    return '🏫 مدرسة تعليمية';
  }

  factory School.fromJson(Map<String, dynamic> json) {
    final nameStr = json['name']?.toString() ?? '';
    final rawType = (json['school_type'] ?? json['stage'])?.toString().toLowerCase() ?? '';

    String detectedType = 'middle';
    if (rawType.isNotEmpty) {
      detectedType = rawType;
    } else if (nameStr.contains('مهن') || nameStr.contains('صناع')) {
      detectedType = 'vocational';
    } else if (nameStr.contains('إعداد') || nameStr.contains('اعداد') || nameStr.contains('متميز')) {
      detectedType = 'academic';
    } else if (nameStr.contains('ابتدائ')) {
      detectedType = 'primary';
    } else if (nameStr.contains('متوسط')) {
      detectedType = 'middle';
    }

    return School(
      id: json['id'] ?? '',
      name: nameStr,
      schoolCode: json['school_code'] ?? '',
      schoolType: detectedType,
      stage: json['stage'] ?? detectedType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'school_code': schoolCode,
      'school_type': schoolType,
      'stage': stage,
    };
  }
}
