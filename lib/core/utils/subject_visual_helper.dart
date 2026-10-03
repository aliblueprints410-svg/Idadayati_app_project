import 'package:flutter/material.dart';

/// مساعد ذكي لتحديد الأيقونات والتدرجات اللونية والهوية البصرية لكل مادة دراسية
/// بأسلوب رصين، أكاديمي، ووقور يليق بطلاب ومهندسي التعليم المهني والإعدادي.
class SubjectVisualHelper {
  /// ترجع الأيقونة المناسبة لاسم المادة بأسلوب أكاديمي هندسي غير طفولي
  static IconData getSubjectIcon(String subjectName) {
    final s = subjectName.trim().toLowerCase();

    // 1. التربية الإسلامية والقرآن الكريم (رمز المصحف الشريف والكتاب الوقور)
    if (s.contains('اسلامية') ||
        s.contains('إسلامية') ||
        s.contains('دين') ||
        s.contains('قرآن') ||
        s.contains('قران') ||
        s.contains('عقيدة') ||
        s.contains('فقه') ||
        s.contains('حديث')) {
      return Icons.menu_book_rounded;
    }

    // 2. اللغة العربية والأدب والبلاغة وقراءتي
    if (s.contains('قراءة') ||
        s.contains('قراءتي') ||
        s.contains('عربي') ||
        s.contains('عربية') ||
        s.contains('لغة عربية') ||
        s.contains('قواعد') ||
        s.contains('أدب') ||
        s.contains('ادب') ||
        s.contains('بلاغة') ||
        s.contains('نصوص')) {
      return s.contains('قراءة') || s.contains('قراءتي') ? Icons.auto_stories_rounded : Icons.history_edu_rounded;
    }

    // 2.1 الاجتماعيات، التاريخ، الجغرافية، التربية الوطنية
    if (s.contains('اجتماعيات') ||
        s.contains('تاريخ') ||
        s.contains('جغراف') ||
        s.contains('وطنية') ||
        s.contains('social')) {
      return Icons.public_rounded;
    }

    // 2.2 علم الأحياء والبيولوجيا
    if (s.contains('أحياء') || s.contains('احياء') || s.contains('biology')) {
      return Icons.biotech_rounded;
    }

    // 2.3 التربية الأخلاقية وعلم النفس والفلسفة
    if (s.contains('اخلاق') || s.contains('أخلاق') || s.contains('فلسفة') || s.contains('نفس')) {
      return Icons.psychology_alt_rounded;
    }

    // 2.4 التربية الفنية والموسيقى
    if (s.contains('فنية') || s.contains('فنون') || s.contains('موسيقى')) {
      return Icons.palette_rounded;
    }

    // 2.5 الاقتصاد والعلوم المالية
    if (s.contains('اقتصاد') || s.contains('مالية') || s.contains('تجارة')) {
      return Icons.trending_up_rounded;
    }

    // 3. الرياضيات والجبر والهندسة التحليلية (رمز الدوال والرياضيات المتقدمة)
    if (s.contains('رياضيات') ||
        s.contains('حساب') ||
        s.contains('جبر') ||
        s.contains('تفاضل') ||
        s.contains('تكامل') ||
        s.contains('math')) {
      return Icons.functions_rounded;
    }

    // 4. الفيزياء والكهرباء
    if (s.contains('فيزياء') ||
        s.contains('كهرباء') ||
        s.contains('كهربائي') ||
        s.contains('physics')) {
      return Icons.bolt_rounded;
    }

    // 5. الكيمياء
    if (s.contains('كيمياء') || s.contains('chemistry')) {
      return Icons.science_rounded;
    }

    // 6. العلوم العامة والطبيعيات
    if (s.contains('طبيعيات') || s.contains('علوم') || s.contains('science')) {
      return Icons.science_rounded;
    }

    // 7. اللغة الإنكليزية واللغات العالمية
    if (s.contains('انكليزي') ||
        s.contains('إنكليزي') ||
        s.contains('انجليزي') ||
        s.contains('إنجليزي') ||
        s.contains('english') ||
        s.contains('لغات')) {
      return Icons.language_rounded;
    }

    // 8. اللغات المحلية الرسمية (تركمانية، كردية)
    if (s.contains('تركي') ||
        s.contains('تركمانية') ||
        s.contains('كردي') ||
        s.contains('كردية')) {
      return Icons.translate_rounded;
    }

    // 9. الرسم الهندسي والصناعي والمعماري
    if (s.contains('رسم هندسي') ||
        s.contains('رسم صناعي') ||
        s.contains('رسم معماري') ||
        s.contains('رسم إنشائي') ||
        s.contains('رسم')) {
      return Icons.architecture_rounded;
    }

    // 10. الأمن السيبراني والتحري الجنائي وإدارة المخاطر
    if (s.contains('سيبراني') ||
        s.contains('أمن') ||
        s.contains('امني') ||
        s.contains('حماية') ||
        s.contains('جنائي') ||
        s.contains('مخاطر') ||
        s.contains('security')) {
      return Icons.security_rounded;
    }

    // 11. شبكات الحاسوب والسحابة
    if (s.contains('شبكات') ||
        s.contains('شبكة') ||
        s.contains('network') ||
        s.contains('سحابية')) {
      return Icons.hub_rounded;
    }

    // 12. المعالجات والتصميم المنطقي والإلكترونيك
    if (s.contains('معالجات') ||
        s.contains('منطقي') ||
        s.contains('إلكترون') ||
        s.contains('الكترون')) {
      return Icons.memory_rounded;
    }

    // 13. الصيانة وتجميع الحاسوب
    if (s.contains('صيانة') || s.contains('تجميع')) {
      return Icons.build_circle_rounded;
    }

    // 14. الحاسوب والبرمجة والتطبيقات
    if (s.contains('حاسوب') ||
        s.contains('تطبيقات الحاسوب') ||
        s.contains('برمجة') ||
        s.contains('computer')) {
      return Icons.terminal_rounded;
    }

    // 15. النفط والتكرير والبتروكيمياويات
    if (s.contains('نفط') ||
        s.contains('تكرير') ||
        s.contains('بتروكيمياو') ||
        s.contains('بترول')) {
      return Icons.local_gas_station_rounded;
    }

    // 16. اللحام وتشكيل المعادن
    if (s.contains('لحام') || s.contains('معادن')) {
      return Icons.hardware_rounded;
    }

    // 17. النجارة وصناعة الأثاث
    if (s.contains('نجارة') ||
        s.contains('نجاره') ||
        s.contains('أثاث') ||
        s.contains('خشب')) {
      return Icons.carpenter_rounded;
    }

    // 18. التكييف والتبريد
    if (s.contains('تكييف') || s.contains('تبريد')) {
      return Icons.ac_unit_rounded;
    }

    // 19. البناء والإنشاءات والمساحة
    if (s.contains('بناء') ||
        s.contains('إنشاء') ||
        s.contains('انشاء') ||
        s.contains('مساحة')) {
      return Icons.apartment_rounded;
    }

    // 20. التدريب العملي والورش والميكانيك والخراطة
    if (s.contains('عملي') ||
        s.contains('ورش') ||
        s.contains('خراطة') ||
        s.contains('تفريز') ||
        s.contains('ميكانيك')) {
      return Icons.precision_manufacturing_rounded;
    }

    // 21. العلوم الصناعية التخصصية
    if (s.contains('صناعية') || s.contains('صناعي') || s.contains('مهارات') || s.contains('مهني')) {
      return Icons.engineering_rounded;
    }

    // 22. اللياقة البدنية والرياضة
    if (s.contains('رياضة') || s.contains('بدنية')) {
      return Icons.fitness_center_rounded;
    }

    return Icons.school_rounded;
  }

  /// ترجع اللون الأساسي الرصين (Mature Tone) لكل مادة
  static Color getSubjectPrimaryColor(String subjectName, [int fallbackIndex = 0]) {
    final s = subjectName.trim().toLowerCase();

    // التربية الإسلامية: زمردي داكن وقور
    if (s.contains('اسلامية') || s.contains('إسلامية') || s.contains('دين') || s.contains('قرآن')) {
      return const Color(0xFF0F766E); // Teal Deep
    }

    // اللغة العربية: كحلي ملكي راقٍ
    if (s.contains('عربي') || s.contains('لغة عربية') || s.contains('قواعد') || s.contains('أدب')) {
      return const Color(0xFF1E3A8A); // Royal Navy
    }

    // الرياضيات: أزرق ياقوتي هندسي
    if (s.contains('رياضيات') || s.contains('حساب') || s.contains('math')) {
      return const Color(0xFF0369A1); // Deep Ocean Blue
    }

    // الفيزياء والكهرباء: نيلي تقني رصين
    if (s.contains('فيزياء') || s.contains('كهرباء')) {
      return const Color(0xFF4338CA); // Deep Indigo
    }

    // الكيمياء والطبيعيات: بنفسجي علمي داكن
    if (s.contains('كيمياء') || s.contains('طبيعيات') || s.contains('علوم')) {
      return const Color(0xFF5B21B6); // Deep Violet
    }

    // اللغة الإنجليزية: أزرق أردوازي احترافي
    if (s.contains('انكليزي') || s.contains('إنكليزي') || s.contains('english')) {
      return const Color(0xFF334155); // Slate
    }

    // اللغات المحلية (تركماني، كردي)
    if (s.contains('تركي') || s.contains('تركمانية') || s.contains('كردي') || s.contains('كردية')) {
      return const Color(0xFF0E7490); // Cyan Dark
    }

    // الرسم الهندسي والصناعي: رصاصي معدني معمارِي
    if (s.contains('رسم')) {
      return const Color(0xFF334155); // Steel Slate
    }

    // الأمن السيبراني: زيتي سيبراني رصين
    if (s.contains('سيبراني') || s.contains('أمن') || s.contains('حماية')) {
      return const Color(0xFF065F46); // Matrix Forest
    }

    // شبكات الحاسوب
    if (s.contains('شبكات') || s.contains('سحابية')) {
      return const Color(0xFF0D9488); // Server Teal
    }

    // المعالجات والصيانة
    if (s.contains('معالجات') || s.contains('صيانة') || s.contains('تجميع') || s.contains('منطقي')) {
      return const Color(0xFF4F46E5); // Indigo Silicon
    }

    // تطبيقات الحاسوب
    if (s.contains('حاسوب') || s.contains('برمجة')) {
      return const Color(0xFF1E293B); // Charcoal Dark
    }

    // النفط والتكرير
    if (s.contains('نفط') || s.contains('تكرير')) {
      return const Color(0xFF78350F); // Petroleum Amber
    }

    // البتروكيمياوي
    if (s.contains('بتروكيمياو') || s.contains('بترو')) {
      return const Color(0xFF6B21A8); // Deep Purple
    }

    // اللحام وتشكيل المعادن
    if (s.contains('لحام') || s.contains('معادن')) {
      return const Color(0xFFC2410C); // Copper Rust
    }

    // النجارة والأثاث
    if (s.contains('نجارة') || s.contains('أثاث') || s.contains('خشب')) {
      return const Color(0xFF854D0E); // Walnut Wood
    }

    // التكييف والتبريد
    if (s.contains('تكييف') || s.contains('تبريد')) {
      return const Color(0xFF0284C7); // Cold Blue
    }

    // البناء والإنشاءات
    if (s.contains('بناء') || s.contains('إنشاء') || s.contains('مساحة')) {
      return const Color(0xFF475569); // Concrete Slate
    }

    // التدريب العملي والورش والميكانيك
    if (s.contains('عملي') || s.contains('ورش') || s.contains('ميكانيك')) {
      return const Color(0xFF991B1B); // Industrial Crimson
    }

    // العلوم الصناعية
    if (s.contains('صناعية') || s.contains('مهارات') || s.contains('مهني')) {
      return const Color(0xFF9A3412); // Bronze
    }

    // الاجتماعيات والتاريخ والجغرافية: نحاسي هادئ وقور
    if (s.contains('اجتماعيات') || s.contains('تاريخ') || s.contains('جغراف') || s.contains('وطنية')) {
      return const Color(0xFFB45309); // Warm Amber/Copper
    }

    // علم الأحياء: زمردي نباتي داكن
    if (s.contains('أحياء') || s.contains('احياء') || s.contains('biology')) {
      return const Color(0xFF047857); // Deep Emerald Green
    }

    // التربية الأخلاقية وعلم النفس والفلسفة: تيل راقٍ
    if (s.contains('اخلاق') || s.contains('أخلاق') || s.contains('فلسفة') || s.contains('نفس')) {
      return const Color(0xFF0F766E); // Deep Teal
    }

    // التربية الفنية: بنفسجي كلاسيكي
    if (s.contains('فنية') || s.contains('فنون')) {
      return const Color(0xFF6D28D9); // Classic Violet
    }

    // الرياضة
    if (s.contains('رياضة') || s.contains('بدنية')) {
      return const Color(0xFF374151); // Gray Sport
    }

    final fallbackColors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF0F766E),
      const Color(0xFF0369A1),
      const Color(0xFF4338CA),
      const Color(0xFF334155),
      const Color(0xFF78350F),
      const Color(0xFF991B1B),
    ];
    return fallbackColors[fallbackIndex % fallbackColors.length];
  }

  /// ترجع تدرجاً لونياً هادئاً ووقوراً
  static List<Color> getSubjectGradient(String subjectName, [int fallbackIndex = 0]) {
    final base = getSubjectPrimaryColor(subjectName, fallbackIndex);
    return [
      base,
      Color.lerp(base, Colors.black, 0.20) ?? base,
    ];
  }

  /// فحص هل المادة وزارية لإظهار شارة فخمة خاصة بها
  static bool isMinisterialSubject(String subjectName) {
    final s = subjectName.trim().toLowerCase();
    return s.contains('وزاري') || s.contains('وزارية') || s.contains('بكالوريا');
  }

  /// استخراج تصنيف المادة (وزاري، عملي، تخصصي، عام)
  static String? getSubjectCategoryTag(String subjectName) {
    final s = subjectName.trim().toLowerCase();
    if (isMinisterialSubject(subjectName)) return 'وزاري';
    if (s.contains('عملي') || s.contains('ورش') || s.contains('مختبر') || s.contains('تدريب')) {
      return 'تدريب عملي';
    }
    if (s.contains('صناعية') || s.contains('رسم') || s.contains('سيبراني') || s.contains('شبكات') || s.contains('معالجات')) {
      return 'تخصصي';
    }
    return null;
  }
}
