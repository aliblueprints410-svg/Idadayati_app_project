class AppConstants {
  static const String appName = 'مدرستي';
  static const String appVersion = 'v 1.0.0';
  static const String appTagline = 'المنصة الذكية للتعليم والتواصل المدرسي';

  // Kirkuk Vocational Preparatory School (إعدادية كركوك المهنية)
  static const String kirkukVocSchoolId = 'f8e7d6c5-b4a3-4210-9876-543210abcdef';
  static const String kirkukVocSchoolCode = 'KIRKUK-VOC';
  static const String kirkukVocSchoolName = 'إعدادية كركوك المهنية';

  // Default School UUID fallback
  static const String defaultSchoolId = kirkukVocSchoolId;

  // Developer Info
  static const String developerName = 'م. علي محمد';
  static const String developerTelegramUrl = 'https://t.me/Ali_Muhammed_410';
  static const String developerTelegramUsername = '@Ali_Muhammed_410';
  static const String developerWhatsapp = '+9647749509636';
  static const String developerWhatsappUrl = 'https://wa.me/9647749509636';
  static const String developerFacebookUrl = 'https://www.facebook.com/profile.php?id=61594838129624';

  static const String supabaseUrlEnvKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyEnvKey = 'SUPABASE_ANON_KEY';

  // Local Storage Keys
  static const String keySchoolCode = 'school_code';
  static const String keySchoolName = 'school_name';
  static const String keySchoolShortCode = 'school_short_code';
  static const String keyStudentName = 'student_name';
  static const String keySelectedDepartment = 'selected_department';
  static const String keySelectedGrade = 'selected_grade';
  static const String keySelectedGradeName = 'selected_grade_name';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyThemeMode = 'theme_mode';

  /// Returns a valid 36-char UUID, falling back safely to defaultSchoolId
  static String sanitizeSchoolId(String? rawId) {
    if (rawId != null && RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(rawId)) {
      return rawId;
    }
    return defaultSchoolId;
  }
}