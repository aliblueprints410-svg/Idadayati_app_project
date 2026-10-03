import 'package:flutter/material.dart';

/// مساعد ذكي لتحديد الأيقونات والتدرجات اللونية والهوية البصرية لكل مادة دراسية
/// بناءً على المنهج العراقي والعربي بشكل دقيق واحترافي.
class SubjectVisualHelper {
  /// ترجع الأيقونة المناسبة لاسم المادة
  static IconData getSubjectIcon(String subjectName) {
    final s = subjectName.trim().toLowerCase();

    // 1. التربية الإسلامية والقرآن الكريم (رمز المصحف الشريف والكتاب الوقور)
    if (s.contains('اسلامية') ||
        s.contains('إسلامية') ||
        s.contains('اسلاميه') ||
        s.contains('إسلاميه') ||
        s.contains('دين') ||
        s.contains('قرآن') ||
        s.contains('قران') ||
        s.contains('عقيدة') ||
        s.contains('حديث') ||
        s.contains('فقه') ||
        s.contains('تفسير') ||
        s.contains('توحيد') ||
        s.contains('تلاوة')) {
      return Icons.menu_book_rounded;
    }

    // 2. اللغة العربية والأدب والبلاغة (رمز قلم الحبر والمخطوطة الأدبية الراقية)
    if (s.contains('قراءة') ||
        s.contains('قراءه') ||
        s.contains('عربي') ||
        s.contains('عربية') ||
        s.contains('عربيه') ||
        s.contains('لغة عربية') ||
        s.contains('لغة') ||
        s.contains('لغتي') ||
        s.contains('قواعد') ||
        s.contains('إملاء') ||
        s.contains('املاء') ||
        s.contains('نصوص') ||
        s.contains('تعبير') ||
        s.contains('بلاغة') ||
        s.contains('أدب') ||
        s.contains('ادب')) {
      return Icons.history_edu_rounded;
    }

    // 3. الرياضيات والجبر والهندسة
    if (s.contains('رياضيات') ||
        s.contains('حساب') ||
        s.contains('جبر') ||
        s.contains('هندسة') ||
        s.contains('هندسه') ||
        s.contains('تفاضل') ||
        s.contains('تكامل') ||
        s.contains('math')) {
      return Icons.calculate_rounded;
    }

    // 4. الأحياء
    if (s.contains('أحياء') || s.contains('احياء') || s.contains('bio')) {
      return Icons.biotech_rounded;
    }

    // 5. الفيزياء
    if (s.contains('فيزياء') || s.contains('physics')) {
      return Icons.bolt_rounded;
    }

    // 6. الكيمياء
    if (s.contains('كيمياء') || s.contains('chemistry')) {
      return Icons.science_rounded;
    }

    // 7. العلوم العامة والبيئة
    if (s.contains('علوم') ||
        s.contains('علم') ||
        s.contains('طبيعيات') ||
        s.contains('science') ||
        s.contains('مختبر')) {
      return Icons.science_rounded;
    }

    // 5. اللغة الإنجليزية واللغات الرسمية المحلية (كردية، تركمانية)
    if (s.contains('انكليزي') ||
        s.contains('إنكليزي') ||
        s.contains('انجليزي') ||
        s.contains('إنجليزي') ||
        s.contains('إنجليزية') ||
        s.contains('انجليزية') ||
        s.contains('english') ||
        s.contains('تركي') ||
        s.contains('تركمانية') ||
        s.contains('كردي') ||
        s.contains('كردية') ||
        s.contains('en')) {
      return Icons.translate_rounded;
    }

    // 6. الاجتماعيات والتاريخ والجغرافيا والوطنية
    if (s.contains('اجتماعيات') ||
        s.contains('تاريخ') ||
        s.contains('جغرافيا') ||
        s.contains('جغرافية') ||
        s.contains('وطنية') ||
        s.contains('مواطنة') ||
        s.contains('اجتماعية') ||
        s.contains('social')) {
      return Icons.public_rounded;
    }

    // 7. التربية الأخلاقية والقيم
    if (s.contains('أخلاق') ||
        s.contains('اخلاق') ||
        s.contains('أخلاقية') ||
        s.contains('اخلاقيه') ||
        s.contains('سلوك') ||
        s.contains('قيم')) {
      return Icons.favorite_rounded;
    }

    // 8. التربية الفنية والرسم الهندسي والصناعي
    if (s.contains('رسم هندسي') ||
        s.contains('رسم صناعي') ||
        s.contains('رسم معماري') ||
        s.contains('رسم إنشائي') ||
        s.contains('رسم')) {
      return Icons.architecture_rounded;
    }
    if (s.contains('فنية') ||
        s.contains('فنيه') ||
        s.contains('أشغال') ||
        s.contains('تشكيلية') ||
        s.contains('art')) {
      return Icons.palette_rounded;
    }

    // 9. التربية الرياضية والبدنية
    if (s.contains('رياضة') ||
        s.contains('رياضه') ||
        s.contains('بدنية') ||
        s.contains('بدنيه') ||
        s.contains('العاب') ||
        s.contains('ألعاب') ||
        s.contains('sport') ||
        s.contains('pe')) {
      return Icons.sports_soccer_rounded;
    }

    // 10. الكهرباء
    if (s.contains('كهرباء') || s.contains('كهربائي')) {
      return Icons.bolt_rounded;
    }

    // 11. الأمن السيبراني والحماية والتحري الجنائي
    if (s.contains('سيبراني') ||
        s.contains('أمن') ||
        s.contains('امني') ||
        s.contains('حماية') ||
        s.contains('جنائي') ||
        s.contains('مخاطر') ||
        s.contains('security')) {
      return Icons.security_rounded;
    }

    // 12. شبكات الحاسوب والسحابة
    if (s.contains('شبكات') || s.contains('شبكة') || s.contains('network') || s.contains('سحابية')) {
      return Icons.hub_rounded;
    }

    // 13. المعالجات والتصميم المنطقي
    if (s.contains('معالجات') || s.contains('منطقي') || s.contains('إلكترون')) {
      return Icons.memory_rounded;
    }

    // 14. الصيانة والتجميع
    if (s.contains('صيانة') || s.contains('تجميع')) {
      return Icons.build_circle_rounded;
    }

    // 15. الحاسوب وتطبيقات الحاسوب والبرمجة
    if (s.contains('حاسوب') ||
        s.contains('كمبيوتر') ||
        s.contains('تطبيقات الحاسوب') ||
        s.contains('تقنية') ||
        s.contains('تكنولوجيا') ||
        s.contains('برمجة') ||
        s.contains('رقمي') ||
        s.contains('computer') ||
        s.contains('it')) {
      return Icons.computer_rounded;
    }

    // 16. الموسيقى والنشيد
    if (s.contains('موسيقى') || s.contains('نشيد') || s.contains('اناشيد')) {
      return Icons.music_note_rounded;
    }

    // 17. النفط والتكرير والبتروكيمياويات
    if (s.contains('نفط') || s.contains('تكرير') || s.contains('بتروكيمياو') || s.contains('بترول')) {
      return Icons.local_gas_station_rounded;
    }

    // 18. اللحام وتشكيل المعادن
    if (s.contains('لحام') || s.contains('معادن')) {
      return Icons.hardware_rounded;
    }

    // 19. النجارة وصناعة الأثاث
    if (s.contains('نجارة') || s.contains('نجاره') || s.contains('أثاث') || s.contains('خشب')) {
      return Icons.carpenter_rounded;
    }

    // 20. التكييف والتبريد
    if (s.contains('تكييف') || s.contains('تبريد')) {
      return Icons.ac_unit_rounded;
    }

    // 21. البناء والإنشاءات والمساحة
    if (s.contains('بناء') || s.contains('إنشاء') || s.contains('انشاء') || s.contains('مساحة')) {
      return Icons.apartment_rounded;
    }

    // 22. التدريب العملي والورش والميكانيك
    if (s.contains('عملي') || s.contains('ورش') || s.contains('خراطة') || s.contains('تفريز') || s.contains('ميكانيك')) {
      return Icons.precision_manufacturing_rounded;
    }

    // 23. العلوم الصناعية
    if (s.contains('صناعية') || s.contains('صناعي') || s.contains('مهارات') || s.contains('مهني')) {
      return Icons.engineering_rounded;
    }

    return Icons.school_rounded;
  }

  /// ترجع تدرجاً لونياً جذاباً ومخصصاً لطبيعة كل مادة
  static List<Color> getSubjectGradient(String subjectName, [int fallbackIndex = 0]) {
    final s = subjectName.trim().toLowerCase();

    // 1. التربية الإسلامية: أخضر زمردي إسلامي وقور
    if (s.contains('اسلامية') ||
        s.contains('إسلامية') ||
        s.contains('دين') ||
        s.contains('قرآن') ||
        s.contains('قران')) {
      return const [Color(0xFF059669), Color(0xFF047857)]; // Emerald
    }

    // 2. القراءة واللغة العربية: أزرق سماوي مشرق
    if (s.contains('قراءة') ||
        s.contains('قراءه') ||
        s.contains('عربي') ||
        s.contains('لغة عربية')) {
      return const [Color(0xFF0284C7), Color(0xFF0369A1)]; // Sky Blue
    }

    // 3. الرياضيات: عنبري برتقالي ذكي ومحفّز
    if (s.contains('رياضيات') || s.contains('حساب') || s.contains('math')) {
      return const [Color(0xFFEA580C), Color(0xFFC2410C)]; // Orange/Amber
    }

    // 4. الأحياء: أخضر طبيعي حيوي
    if (s.contains('أحياء') || s.contains('احياء') || s.contains('bio')) {
      return const [Color(0xFF16A34A), Color(0xFF15803D)]; // Forest Green
    }

    // 5. الفيزياء والكهرباء: كحلي نيلي كهربائي حديث
    if (s.contains('فيزياء') || s.contains('كهرباء') || s.contains('physics')) {
      return const [Color(0xFF4F46E5), Color(0xFF3730A3)]; // Indigo
    }

    // 6. الكيمياء: بنفسجي مخبري متألق
    if (s.contains('كيمياء') || s.contains('chemistry')) {
      return const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]; // Violet
    }

    // 7. العلوم العامة والطبيعيات: أرجواني عصري
    if (s.contains('طبيعيات') || s.contains('علوم') || s.contains('science')) {
      return const [Color(0xFF9333EA), Color(0xFF7E22CE)]; // Purple
    }

    // 8. الإنجليزية واللغات المحلية
    if (s.contains('انكليزي') ||
        s.contains('إنكليزي') ||
        s.contains('انجليزي') ||
        s.contains('english')) {
      return const [Color(0xFFE11D48), Color(0xFFBE123C)]; // Rose
    }
    if (s.contains('تركي') || s.contains('تركمانية') || s.contains('كردي') || s.contains('كردية')) {
      return const [Color(0xFF0891B2), Color(0xFF0E7490)]; // Cyan/Teal
    }

    // 9. الأمن السيبراني والشبكات
    if (s.contains('سيبراني') || s.contains('أمن') || s.contains('حماية') || s.contains('شبكات')) {
      return const [Color(0xFF0F766E), Color(0xFF115E59)]; // Deep Teal
    }

    // 10. النفط والتكرير والبتروكيمياوي
    if (s.contains('نفط') || s.contains('تكرير') || s.contains('بتروكيمياو')) {
      return const [Color(0xFFB45309), Color(0xFF92400E)]; // Amber Brown
    }

    // 11. اللحام
    if (s.contains('لحام')) {
      return const [Color(0xFFC2410C), Color(0xFF9A3412)]; // Copper Orange
    }

    // 12. النجارة
    if (s.contains('نجارة') || s.contains('أثاث')) {
      return const [Color(0xFF854D0E), Color(0xFF713F12)]; // Wood Warm Amber
    }

    // 13. التكييف والتبريد
    if (s.contains('تكييف') || s.contains('تبريد')) {
      return const [Color(0xFF0284C7), Color(0xFF0369A1)]; // Cool Cyan
    }

    // 14. البناء والإنشاءات والرسم الهندسي
    if (s.contains('بناء') || s.contains('رسم')) {
      return const [Color(0xFF475569), Color(0xFF334155)]; // Slate Steel
    }

    // 15. التدريب العملي والورش والميكانيك
    if (s.contains('عملي') || s.contains('ورش') || s.contains('ميكانيك')) {
      return const [Color(0xFFDC2626), Color(0xFFB91C1C)]; // Industrial Crimson
    }

    // 16. الحاسوب والمعالجات
    if (s.contains('حاسوب') || s.contains('كمبيوتر') || s.contains('تقنية') || s.contains('معالجات')) {
      return const [Color(0xFF4F46E5), Color(0xFF3730A3)]; // Indigo
    }

    // 17. الرياضة
    if (s.contains('رياضة') || s.contains('بدنية')) {
      return const [Color(0xFF10B981), Color(0xFF059669)]; // Mint
    }

    // في حال عدم التعرف، نستخدم دورة الألوان الأساسية
    final defaultPalette = [
      const [Color(0xFF6366F1), Color(0xFF4338CA)],
      const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      const [Color(0xFF10B981), Color(0xFF059669)],
      const [Color(0xFFF59E0B), Color(0xFFD97706)],
      const [Color(0xFFEC4899), Color(0xFFDB2777)],
      const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      const [Color(0xFF14B8A6), Color(0xFF0F766E)],
      const [Color(0xFFF43F5E), Color(0xFFE11D48)],
    ];
    return defaultPalette[fallbackIndex % defaultPalette.length];
  }

  /// ويدجت أيقونة المادة الفخمة ثلاثية الأبعاد والمريحة بصرياً
  static Widget buildSubjectIconBadge({
    required String subjectName,
    double size = 58,
    double iconSize = 28,
    double borderRadius = 18,
    int fallbackIndex = 0,
    bool showGlow = true,
  }) {
    final icon = getSubjectIcon(subjectName);
    final gradient = getSubjectGradient(subjectName, fallbackIndex);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.4,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
