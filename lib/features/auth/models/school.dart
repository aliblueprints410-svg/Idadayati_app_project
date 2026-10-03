class School {
  final String id;
  final String name;
  final String schoolCode;
  final String stage; // 'vocational', 'preparatory', 'middle', 'primary'

  const School({
    required this.id,
    required this.name,
    required this.schoolCode,
    this.stage = 'vocational',
  });

  bool get isVocational =>
      stage.toLowerCase() == 'vocational' ||
      name.contains('مهن') ||
      name.contains('إعداد') ||
      name.contains('اعداد') ||
      name.contains('صناع');

  bool get isMiddle => stage.toLowerCase() == 'middle' || name.contains('متوسط');
  bool get isPrimary => !isVocational && !isMiddle;

  factory School.fromJson(Map<String, dynamic> json) {
    final nameStr = json['name']?.toString() ?? '';
    String defaultStage = 'vocational';
    if (nameStr.contains('متوسط')) {
      defaultStage = 'middle';
    } else if (nameStr.contains('ابتدائ')) {
      defaultStage = 'primary';
    }

    return School(
      id: json['id'] ?? '',
      name: nameStr,
      schoolCode: json['school_code'] ?? '',
      stage: json['stage'] ?? defaultStage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'school_code': schoolCode,
      'stage': stage,
    };
  }
}
