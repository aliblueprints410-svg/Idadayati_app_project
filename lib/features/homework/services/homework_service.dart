import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_tables.dart';
import '../../../core/utils/arabic_day_helper.dart';
import '../models/homework.dart';
import '../models/school_class.dart';
import '../models/subject.dart';

class HomeworkService {
  final SupabaseClient _supabase;

  HomeworkService(this._supabase);

  static const String _sysSubjectsPrefix = '__SYS_SUBJECTS_V2__:';
  static const String _localSubjectsKeyPrefix = 'subjects_v2_override_';
  static const String _localSubjectsRevKeyPrefix = 'subjects_v2_rev_';
  static const String _sysHomeworkPrefix = '__SYS_HOMEWORK__:';
  static const String _localHomeworkKeyPrefix = 'local_homework_';
  static const String _archivedHomeworkIdsKey = 'archived_homework_ids';

  ({int rev, List<Subject> subjects})? _parseSubjectsPayload(String? raw, int fallbackRev) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final rev = (decoded['rev'] is num) ? (decoded['rev'] as num).toInt() : fallbackRev;
        final rawList = decoded['subjects'] as List? ?? [];
        final list = rawList
            .map((e) => Subject.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return (rev: rev, subjects: list);
      } else if (decoded is List) {
        final list = decoded
            .map((e) => Subject.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return (rev: fallbackRev, subjects: list);
      }
    } catch (_) {}
    return null;
  }

  // Return official curriculum subjects based on grade name / class name
  List<String> getSubjectsListForGrade(String gradeName) {
    final name = gradeName.toLowerCase();

    // 1. المرحلة الابتدائية (الصفوف 1 - 6)
    if (name.contains('ابتدائ') || name.contains('ابتدائي')) {
      if (name.contains('سادس') || name.contains('6') || name.contains('بكالوريا') || name.contains('وزاري')) {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'الرياضيات',
          'العلوم',
          'اللغة الإنكليزية',
          'الاجتماعيات',
        ];
      } else if (name.contains('رابع') || name.contains('خامس') || name.contains('4') || name.contains('5')) {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'الرياضيات',
          'العلوم',
          'اللغة الإنكليزية',
          'الاجتماعيات',
          'التربية الفنية',
          'التربية الرياضية',
        ];
      } else {
        // الأول والثاني والثالث الابتدائي
        return [
          'التربية الإسلامية',
          'قراءتي',
          'الرياضيات',
          'العلوم',
          'اللغة الإنكليزية',
          'التربية الأخلاقية',
          'التربية الرياضية',
          'التربية الفنية',
        ];
      }
    }

    // 2. المرحلة المتوسطة (الأول والثاني والثالث متوسط)
    if (name.contains('متوسط')) {
      if (name.contains('ثالث') || name.contains('3') || name.contains('وزاري')) {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'اللغة الإنكليزية',
          'الرياضيات',
          'الاجتماعيات',
          'الأحياء',
          'الكيمياء',
          'الفيزياء',
        ];
      } else {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'اللغة الإنكليزية',
          'الرياضيات',
          'العلوم',
          'الاجتماعيات',
          'الحاسوب',
          'التربية الأخلاقية',
          'التربية الفنية',
          'التربية الرياضية',
        ];
      }
    }

    // 3. المرحلة الإعدادية الأكاديمية (علمي / أدبي)
    if (name.contains('علمي') ||
        name.contains('أدبي') ||
        (!name.contains('مهن') && !name.contains('صناع') && (name.contains('إعداد') || name.contains('اعداد')))) {
      if (name.contains('أدبي') || name.contains('ادبي')) {
        if (name.contains('سادس') || name.contains('6') || name.contains('وزاري')) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'التاريخ',
            'الجغرافية',
            'الاقتصاد',
          ];
        } else if (name.contains('خامس') || name.contains('5')) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'التاريخ',
            'الجغرافية',
            'الفلسفة وعلم النفس',
            'الحاسوب',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'التاريخ',
            'الجغرافية',
            'علم الاجتماع',
            'الحاسوب',
          ];
        }
      } else {
        // الفرع العلمي
        if (name.contains('سادس') || name.contains('6') || name.contains('وزاري')) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الأحياء',
            'الكيمياء',
            'الفيزياء',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الفيزياء',
            'الكيمياء',
            'الأحياء',
            'الحاسوب',
          ];
        }
      }
    }

    // 4. التعليم المهني (وفق جدول إعدادية كركوك المهنية وأقسامها)
    if (name.contains('مهني') ||
        name.contains('صناعي') ||
        name.contains('ورش') ||
        name.contains('قسم') ||
        name.contains('سيبراني') ||
        name.contains('حاسوب') ||
        name.contains('كهرباء') ||
        name.contains('ميكانيك') ||
        name.contains('سيارات') ||
        name.contains('الكترون') ||
        name.contains('إلكترون') ||
        name.contains('تبريد') ||
        name.contains('تكييف') ||
        name.contains('بناء') ||
        name.contains('اتصالات') ||
        name.contains('طبي') ||
        name.contains('نجار') ||
        name.contains('نفط') ||
        name.contains('لحام') ||
        name.contains('بترو')) {
      final isThird = name.contains('ثالث') || name.contains('3');
      final isSecond = name.contains('ثاني') || name.contains('2');

      // 1. أمن سيبراني
      if (name.contains('سيبراني') || name.contains('أمن') || name.contains('امني')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'أمن الشبكات والمعلومات',
            'التحري الرقمي الجنائي',
            'مختبر الأمن السيبراني المتقدم',
            'إدارة المخاطر السيبرانية',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'أساسيات الأمن السيبراني',
            'حماية أنظمة التشغيل (نظري)',
            'مختبر حماية أنظمة التشغيل',
            'أمن الشبكات والحوسبة السحابية',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'أساسيات الكهرباء (نظري)',
            'مختبر أساسيات الكهرباء',
            'شبكات الحاسوب',
            'المبادئ الأساسية للحاسوب',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 2. حاسوب (تجميع وصيانة / شبكات)
      if (name.contains('حاسوب') || name.contains('كمبيوتر')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'المعالجات الدقيقة',
            'شبكات الحاسوب',
            'صيانة الحاسوب المتقدمة',
            'مختبر شبكات الحاسوب',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'شبكات الحاسوب',
            'صيانة الحاسوب',
            'التصميم المنطقي',
            'تطبيقات الحاسوب',
            'مختبر الصيانة والشبكات',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'المبادئ الأساسية للحاسوب',
            'تجميع وصيانة الحاسوب (نظري)',
            'مختبر تجميع وصيانة الحاسوب',
            'تطبيقات الحاسوب',
            'شبكات الحاسوب',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 3. تكييف وتبريد
      if (name.contains('تكييف') || name.contains('تبريد')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية (مكائن ومنظومات التبريد)',
            'التدريب العملي ومشاريع التبريد والتكييف',
            'الرسم الصناعي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (منظومات التبريد والتكييف)',
            'التدريب العملي (ورشة التكييف والتبريد)',
            'الرسم الصناعي',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (تكييف وتبريد)',
            'التدريب العملي (ورشة التبريد والتكييف)',
            'الرسم الهندسي والصناعي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 4. تكرير نفط
      if (name.contains('تكرير') || (name.contains('نفط') && !name.contains('بترو'))) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية (الصناعات النفطية والتكرير)',
            'التدريب العملي المتقدم',
            'الرسم الصناعي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (عمليات تكرير النفط)',
            'التدريب العملي (مختبرات وورش التكرير)',
            'الرسم الصناعي',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (تكرير النفط)',
            'التدريب العملي (ورش ومختبرات النفط)',
            'تطبيقات الحاسوب',
            'الرسم الهندسي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 5. بتروكيمياوي
      if (name.contains('بتروكيمياو') || name.contains('بترو')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية (عمليات بتروكيمياوية)',
            'التدريب العملي المتقدم',
            'الرسم الصناعي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (العمليات البتروكيمياوية)',
            'التدريب العملي (ورش ومختبرات)',
            'الرسم الصناعي',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (صناعات بتروكيمياوية)',
            'التدريب العملي',
            'تطبيقات الحاسوب',
            'الرسم الهندسي والصناعي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 6. بناء
      if (name.contains('بناء')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية (تكنولوجيا البناء والمشاريع)',
            'التدريب العملي ومشاريع البناء',
            'الرسم الإنشائي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (إنشاء مباني ومساحة)',
            'التدريب العملي (بناء وإنشاءات)',
            'الرسم المعماري والإنشائي',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (تكنولوجيا البناء)',
            'التدريب العملي (ورشة البناء)',
            'الرسم الهندسي الإنشائي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 7. نجارة
      if (name.contains('نجارة') || name.contains('نجاره')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية (تكنولوجيا النجارة)',
            'التدريب العملي والإنتاج',
            'الرسم الصناعي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (صناعة الأثاث والديكور)',
            'التدريب العملي (مختبر وورش النجارة)',
            'الرسم الصناعي والتصميم',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (نجارة عامة)',
            'التدريب العملي (ورشة النجارة)',
            'الرسم الهندسي والصناعي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 8. ميكانيك
      if (name.contains('ميكانيك')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية',
            'التدريب العملي ومشاريع التخرج',
            'الرسم الميكانيكي والهندسي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (مكائن وتشغيل ميكانيكي)',
            'التدريب العملي (ورش الخراطة والتفريز)',
            'الرسم الميكانيكي والصناعي',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (ميكانيك عام)',
            'التدريب العملي (ورشة الخراطة والبرادة)',
            'الرسم الهندسي والصناعي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // 9. لحام
      if (name.contains('لحام')) {
        if (isThird) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات التطبيقية',
            'الطبيعيات',
            'العلوم الصناعية (لحام متقدم وفحص الوصلات)',
            'التدريب العملي ومشاريع التشكيل',
            'الرسم الصناعي الميكانيكي',
          ];
        } else if (isSecond) {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (تقنيات اللحام والوصل)',
            'التدريب العملي (لحام القوس الكهربائي والغاز)',
            'الرسم الصناعي',
            'اللغة التركمانية والكردية',
          ];
        } else {
          return [
            'التربية الإسلامية',
            'اللغة العربية',
            'اللغة الإنكليزية',
            'الرياضيات',
            'الطبيعيات',
            'العلوم الصناعية (لحام وتشكيل معادن)',
            'التدريب العملي (ورشة اللحام الأساسية)',
            'الرسم الهندسي والصناعي',
            'الرياضة',
            'اللغة التركمانية والكردية',
          ];
        }
      }

      // الافتراضي للمهني العام
      if (isThird) {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'اللغة الإنجليزية',
          'الرياضيات المهنية',
          'العلوم الصناعية',
          'الرسم الصناعي والهندسي',
          'التدريب العملي ومشاريع التخرج',
        ];
      } else if (isSecond) {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'اللغة الإنجليزية',
          'الرياضيات التطبيقية',
          'العلوم الصناعية',
          'الرسم الصناعي',
          'التدريب العملي والورش',
        ];
      } else {
        return [
          'التربية الإسلامية',
          'اللغة العربية',
          'اللغة الإنجليزية',
          'الرياضيات العامة',
          'الفيزياء والطبيعيات',
          'العلوم الصناعية',
          'الرسم الهندسي والصناعي',
          'التدريب العملي والورش',
        ];
      }
    }

    // الافتراضي العام
    return [
      'التربية الإسلامية',
      'اللغة العربية',
      'اللغة الإنكليزية',
      'الرياضيات',
      'العلوم',
    ];
  }

  // Get classes for a specific school (with automatic provisioning for vocational & new schools)
  Future<List<SchoolClass>> getClasses(String schoolId) async {
    final cleanSchoolId = AppConstants.sanitizeSchoolId(schoolId);

    try {
      final response = await _supabase
          .from(AppTables.classes)
          .select()
          .eq('school_id', cleanSchoolId)
          .order('grade_level', ascending: true);

      final list = (response as List).map((e) => SchoolClass.fromJson(e)).toList();
      if (list.isNotEmpty) {
        // تنقية وإزالة التكرار لضمان عدم تكرار أي صف في أي قسم مطلقاً
        final seenClassKeys = <String>{};
        final List<SchoolClass> uniqueClasses = [];
        for (final c in list) {
          final cleanKey = c.name
              .replaceAll('(وزاري)', '')
              .replaceAll('(بكالوريا)', '')
              .replaceAll('  ', ' ')
              .trim();
          if (!seenClassKeys.contains(cleanKey) || c.name.contains('وزاري') || c.name.contains('بكالوريا')) {
            if (seenClassKeys.contains(cleanKey)) {
              uniqueClasses.removeWhere((item) =>
                  item.name.replaceAll('(وزاري)', '').replaceAll('(بكالوريا)', '').trim() == cleanKey);
            }
            seenClassKeys.add(cleanKey);
            uniqueClasses.add(c);
          }
        }
        return uniqueClasses;
      }
    } catch (_) {}

    // Check school type from taleb_schools
    String schoolType = 'vocational';
    try {
      final sRow = await _supabase
          .from(AppTables.schools)
          .select('school_type, stage, name')
          .eq('id', cleanSchoolId)
          .maybeSingle();
      if (sRow != null) {
        final rawType = (sRow['school_type'] ?? sRow['stage'])?.toString().toLowerCase() ?? '';
        final sName = sRow['name']?.toString() ?? '';
        if (rawType.isNotEmpty) {
          schoolType = rawType;
        } else if (sName.contains('متوسط')) {
          schoolType = 'middle';
        } else if (sName.contains('ابتدائ')) {
          schoolType = 'primary';
        } else if (sName.contains('إعداد') || sName.contains('اعداد') || sName.contains('متميز')) {
          schoolType = 'academic';
        }
      }
    } catch (_) {}

    const uuid = Uuid();
    final List<SchoolClass> generatedClasses = [];
    final List<Map<String, dynamic>> toInsert = [];
    int orderCounter = 1;

    if (schoolType == 'primary') {
      final primaryNames = [
        'الأول الابتدائي',
        'الثاني الابتدائي',
        'الثالث الابتدائي',
        'الرابع الابتدائي',
        'الخامس الابتدائي',
        'السادس الابتدائي (بكالوريا)',
      ];
      for (final pName in primaryNames) {
        final cId = uuid.v5(Namespace.url.value, 'taleb_class_${cleanSchoolId}_$orderCounter');
        generatedClasses.add(SchoolClass(
          id: cId,
          schoolId: cleanSchoolId,
          name: pName,
          order: orderCounter,
        ));
        toInsert.add({
          'id': cId,
          'school_id': cleanSchoolId,
          'name': pName,
          'order': orderCounter,
        });
        orderCounter++;
      }
    } else if (schoolType == 'middle') {
      final middleNames = [
        'الأول المتوسط',
        'الثاني المتوسط',
        'الثالث المتوسط (وزاري)',
      ];
      for (final mName in middleNames) {
        final cId = uuid.v5(Namespace.url.value, 'taleb_class_${cleanSchoolId}_$orderCounter');
        generatedClasses.add(SchoolClass(
          id: cId,
          schoolId: cleanSchoolId,
          name: mName,
          order: orderCounter,
        ));
        toInsert.add({
          'id': cId,
          'school_id': cleanSchoolId,
          'name': mName,
          'order': orderCounter,
        });
        orderCounter++;
      }
    } else if (schoolType == 'academic') {
      final academicNames = [
        'الرابع العلمي',
        'الرابع الأدبي',
        'الخامس العلمي',
        'الخامس الأدبي',
        'السادس العلمي (وزاري)',
        'السادس الأدبي (وزاري)',
      ];
      for (final aName in academicNames) {
        final cId = uuid.v5(Namespace.url.value, 'taleb_class_${cleanSchoolId}_$orderCounter');
        generatedClasses.add(SchoolClass(
          id: cId,
          schoolId: cleanSchoolId,
          name: aName,
          order: orderCounter,
        ));
        toInsert.add({
          'id': cId,
          'school_id': cleanSchoolId,
          'name': aName,
          'order': orderCounter,
        });
        orderCounter++;
      }
    } else {
      // Auto-provision 27 vocational classes across 9 departments for Vocational Schools
      final List<String> vocationalDepartments = [
        'ميكانيك',
        'أمن سيبراني',
        'نجارة',
        'بناء',
        'حاسوب',
        'تكييف',
        'تكرير نفط',
        'لحام',
        'بتروكيمياوي',
      ];

      for (final dept in vocationalDepartments) {
        final stages = ['الأول مهني', 'الثاني مهني', 'الثالث مهني'];
        for (int s = 0; s < stages.length; s++) {
          final className = '${stages[s]} - $dept';
          final cId = uuid.v5(Namespace.url.value, 'taleb_class_${cleanSchoolId}_$orderCounter');
          generatedClasses.add(SchoolClass(
            id: cId,
            schoolId: cleanSchoolId,
            name: className,
            order: orderCounter,
          ));
          toInsert.add({
            'id': cId,
            'school_id': cleanSchoolId,
            'name': className,
            'order': orderCounter,
          });
          orderCounter++;
        }
      }
    }

    try {
      await _supabase.from(AppTables.classes).insert(toInsert);
    } catch (_) {}

    return generatedClasses;
  }

  // Get subjects for a specific class (with monotonic revision comparison between local & cloud)
  Future<List<Subject>> getSubjects(String classId) async {
    ({int rev, List<Subject> subjects})? localParsed;

    try {
      final prefs = await SharedPreferences.getInstance();
      final localRaw = prefs.getString('$_localSubjectsKeyPrefix$classId');
      final localRev = prefs.getInt('$_localSubjectsRevKeyPrefix$classId') ?? 0;
      localParsed = _parseSubjectsPayload(localRaw, localRev);
    } catch (_) {}

    // 1. Check cloud overrides in announcements system rows and find highest revision
    ({int rev, List<Subject> subjects})? cloudBest;
    String? cloudBestRaw;
    try {
      final sysTitle = '$_sysSubjectsPrefix$classId';
      final sysRows = await _supabase
          .from(AppTables.announcements)
          .select('content, created_at')
          .eq('title', sysTitle)
          .order('created_at', ascending: false)
          .limit(10);

      for (final row in (sysRows as List)) {
        final rawContent = row['content'] as String?;
        final createdAtStr = row['created_at'] as String?;
        final fallbackTs = createdAtStr != null
            ? (DateTime.tryParse(createdAtStr)?.millisecondsSinceEpoch ?? 0)
            : 0;
        final parsed = _parseSubjectsPayload(rawContent, fallbackTs);
        if (parsed != null && (cloudBest == null || parsed.rev > cloudBest.rev)) {
          cloudBest = parsed;
          cloudBestRaw = rawContent;
        }
      }
    } catch (_) {}

    if (cloudBest != null && (localParsed == null || cloudBest.rev > localParsed.rev)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (cloudBestRaw != null) {
          await prefs.setString('$_localSubjectsKeyPrefix$classId', cloudBestRaw);
        }
        await prefs.setInt('$_localSubjectsRevKeyPrefix$classId', cloudBest.rev);
      } catch (_) {}
      return await _sanitizeAndFilterSubjectsForClass(classId, cloudBest.subjects);
    }

    // 2. Return local override if present (and >= cloudBest.rev)
    if (localParsed != null) {
      return await _sanitizeAndFilterSubjectsForClass(classId, localParsed.subjects);
    }

    // 3. Query subjects table in Supabase
    try {
      final response = await _supabase
          .from(AppTables.subjects)
          .select()
          .eq('class_id', classId);

      final list = (response as List).map((e) => Subject.fromJson(e)).toList();
      if (list.isNotEmpty) {
        return await _sanitizeAndFilterSubjectsForClass(classId, list);
      }

      // If empty in database, get class name to return official grade subjects
      return await _generateFallbackSubjects(classId);
    } catch (_) {
      return await _generateFallbackSubjects(classId);
    }
  }

  // Ensure strict stage isolation & eliminate duplicate subjects
  Future<List<Subject>> _sanitizeAndFilterSubjectsForClass(
    String classId,
    List<Subject> rawList,
  ) async {
    String className = '';
    if (classId == 'c1111111-1111-4111-8111-111111111111') {
      className = 'الصف الأول المتوسط';
    } else if (classId == 'c2222222-2222-4222-8222-222222222222') {
      className = 'الصف الثاني المتوسط';
    } else if (classId == 'c3333333-3333-4333-8333-333333333333') {
      className = 'الصف الثالث المتوسط';
    } else {
      try {
        final cRes = await _supabase
            .from(AppTables.classes)
            .select('name')
            .eq('id', classId)
            .maybeSingle();
        if (cRes != null && cRes['name'] != null) {
          className = cRes['name'] as String;
        }
      } catch (_) {}
    }

    final isMiddleClass = className.contains('متوسط');
    final isPrimaryClass = className.contains('ابتدائي');

    // Strict stage filtering
    final filtered = rawList.where((s) {
      final name = s.name.trim();
      if (isMiddleClass) {
        // Middle school should never contain primary-only subjects
        if (name == 'القراءة' || name == 'العلوم') return false;
      } else if (isPrimaryClass) {
        // Primary school should never contain middle-only subjects
        if (name == 'الأحياء' ||
            name == 'الاحياء' ||
            name == 'الفيزياء' ||
            name == 'الكيمياء') {
          return false;
        }
      }
      return true;
    }).toList();

    // Deduplicate by trimmed name
    final seen = <String>{};
    final List<Subject> deduplicated = [];
    for (final s in filtered) {
      final key = s.name.trim().toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        deduplicated.add(s);
      }
    }

    return deduplicated.isNotEmpty
        ? deduplicated
        : await _generateFallbackSubjects(classId);
  }

  Future<void> _saveSubjectsOverride(String classId, List<Subject> subjects) async {
    final nowUtc = DateTime.now().toUtc();
    final nowMs = nowUtc.millisecondsSinceEpoch;
    int prevRev = 0;
    String schoolId = AppConstants.defaultSchoolId;

    try {
      final prefs = await SharedPreferences.getInstance();
      prevRev = prefs.getInt('$_localSubjectsRevKeyPrefix$classId') ?? 0;
      schoolId = AppConstants.sanitizeSchoolId(prefs.getString(AppConstants.keySchoolCode));
    } catch (_) {}

    final newRev = (prevRev >= nowMs ? prevRev : nowMs) + 1;
    final payloadStr = jsonEncode({
      'rev': newRev,
      'subjects': subjects.map((s) => s.toJson()).toList(),
    });

    // 1. Save locally with strictly higher monotonic revision
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_localSubjectsKeyPrefix$classId', payloadStr);
      await prefs.setInt('$_localSubjectsRevKeyPrefix$classId', newRev);
    } catch (_) {}

    // 2. Sync to cloud via append-only INSERT into announcements
    try {
      final sysTitle = '$_sysSubjectsPrefix$classId';
      await _supabase.from(AppTables.announcements).insert({
        'id': const Uuid().v4(),
        'school_id': schoolId,
        'title': sysTitle,
        'content': payloadStr,
        'created_at': nowUtc.toIso8601String(),
        'priority': false,
        'is_deleted': false,
      });
    } catch (e) {
      debugPrint('[HomeworkService] Cloud subjects sync notice: $e');
    }
  }

  // Add a new subject for a class (Teacher)
  Future<void> addSubject(String classId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final current = await getSubjects(classId);
    final newSubject = Subject(
      id: const Uuid().v4(),
      classId: classId,
      name: trimmed,
    );

    try {
      await _supabase.from(AppTables.subjects).insert({
        'id': newSubject.id,
        'class_id': classId,
        'name': trimmed,
      });
    } catch (e) {
      debugPrint('[HomeworkService] Direct addSubject fallback: $e');
    }

    await _saveSubjectsOverride(classId, [...current, newSubject]);
  }

  // Update an existing subject name (Teacher)
  Future<void> updateSubject(
    String classId,
    String subjectId,
    String newName, {
    String? oldName,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final current = await getSubjects(classId);
    bool matched = false;
    final updated = current.map((s) {
      if (s.id == subjectId ||
          (!matched && oldName != null && s.name.trim() == oldName.trim())) {
        matched = true;
        return Subject(id: s.id, classId: s.classId, name: trimmed, icon: s.icon);
      }
      return s;
    }).toList();

    try {
      await _supabase
          .from(AppTables.subjects)
          .update({'name': trimmed})
          .eq('id', subjectId);
    } catch (e) {
      debugPrint('[HomeworkService] Direct updateSubject fallback: $e');
    }

    await _saveSubjectsOverride(classId, updated);
  }

  // Delete a subject (Teacher)
  Future<void> deleteSubject(String classId, String subjectId) async {
    final current = await getSubjects(classId);
    final updated = current.where((s) => s.id != subjectId).toList();

    try {
      await _supabase.from(AppTables.subjects).delete().eq('id', subjectId);
    } catch (e) {
      debugPrint('[HomeworkService] Direct deleteSubject fallback: $e');
    }

    await _saveSubjectsOverride(classId, updated);
  }

  Future<List<Subject>> _generateFallbackSubjects(String classId) async {
    String gradeName = '';
    if (classId == 'c1111111-1111-4111-8111-111111111111') {
      gradeName = 'الصف الأول المتوسط';
    } else if (classId == 'c2222222-2222-4222-8222-222222222222') {
      gradeName = 'الصف الثاني المتوسط';
    } else if (classId == 'c3333333-3333-4333-8333-333333333333') {
      gradeName = 'الصف الثالث المتوسط';
    } else {
      try {
        final classRes = await _supabase
            .from(AppTables.classes)
            .select('name')
            .eq('id', classId)
            .maybeSingle();
        if (classRes != null && classRes['name'] != null) {
          gradeName = classRes['name'] as String;
        }
      } catch (_) {}
    }

    if (gradeName.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        gradeName = prefs.getString('selected_grade_name') ?? '';
      } catch (_) {}
    }

    final subjectNames = getSubjectsListForGrade(gradeName);
    return subjectNames.map((name) {
      final deterministicId = 'subj_${classId.hashCode.abs()}_${name.hashCode.abs()}';
      return Subject(
        id: deterministicId,
        classId: classId,
        name: name,
      );
    }).toList();
  }

  // Seed default primary subjects for a specific class to Supabase (Teacher)
  Future<void> seedDefaultSubjectsForClass(String classId, String className) async {
    final officialNames = getSubjectsListForGrade(className);
    const uuid = Uuid();

    // Fetch existing DB subjects first so we preserve real DB UUIDs if they exist
    List<Subject> dbSubjects = [];
    try {
      final response = await _supabase
          .from(AppTables.subjects)
          .select()
          .eq('class_id', classId);
      dbSubjects = (response as List).map((e) => Subject.fromJson(e)).toList();
    } catch (_) {}

    final current = await getSubjects(classId);
    final List<Subject> merged = List<Subject>.from(current);
    final List<Map<String, dynamic>> toInsert = [];

    for (final name in officialNames) {
      final exists = merged.any((s) => s.name.trim() == name.trim());
      if (!exists) {
        final dbMatch = dbSubjects.where((s) => s.name.trim() == name.trim()).toList();
        final newId = dbMatch.isNotEmpty ? dbMatch.first.id : uuid.v4();
        final subj = Subject(id: newId, classId: classId, name: name);
        merged.add(subj);
        if (dbMatch.isEmpty) {
          toInsert.add({
            'id': newId,
            'class_id': classId,
            'name': name,
          });
        }
      }
    }

    if (toInsert.isNotEmpty) {
      try {
        await _supabase.from(AppTables.subjects).insert(toInsert);
      } catch (e) {
        debugPrint('[HomeworkService] Direct seedDefaultSubjects fallback: $e');
      }
    }

    await _saveSubjectsOverride(classId, merged);
  }

  static const String _sysResetYearPrefix = '__SYS_RESET_YEAR__:';

  /// Returns homework IDs completed locally by the student on THIS device only.
  Future<Set<String>> getStudentCompletedHomeworkIds([String? schoolId]) async {
    final Set<String> ids = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanSchoolId = AppConstants.sanitizeSchoolId(
        schoolId ?? prefs.getString(AppConstants.keySchoolCode),
      );
      ids.addAll(prefs.getStringList('${_archivedHomeworkIdsKey}_$cleanSchoolId') ?? []);
      if (cleanSchoolId == AppConstants.defaultSchoolId) {
        ids.addAll(prefs.getStringList(_archivedHomeworkIdsKey) ?? []);
      }
    } catch (_) {}
    return ids;
  }

  Future<DateTime?> _getSchoolResetTimestamp([String? schoolId]) async {
    String cleanSchoolId = AppConstants.defaultSchoolId;
    DateTime? localResetTs;

    try {
      final prefs = await SharedPreferences.getInstance();
      cleanSchoolId = AppConstants.sanitizeSchoolId(
        schoolId ?? prefs.getString(AppConstants.keySchoolCode),
      );
      final localRaw = prefs.getString('reset_year_ts_$cleanSchoolId');
      if (localRaw != null && localRaw.isNotEmpty) {
        localResetTs = DateTime.tryParse(localRaw)?.toUtc();
      }
    } catch (_) {}

    try {
      final sysTitle = '$_sysResetYearPrefix$cleanSchoolId';
      final rows = await _supabase
          .from(AppTables.announcements)
          .select('content')
          .eq('title', sysTitle)
          .order('created_at', ascending: false)
          .limit(5);

      DateTime? cloudBest;
      for (final r in (rows as List)) {
        final raw = r['content']?.toString();
        if (raw != null && raw.isNotEmpty) {
          final parsed = DateTime.tryParse(raw)?.toUtc();
          if (parsed != null && (cloudBest == null || parsed.isAfter(cloudBest))) {
            cloudBest = parsed;
          }
        }
      }

      if (cloudBest != null && (localResetTs == null || cloudBest.isAfter(localResetTs))) {
        localResetTs = cloudBest;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reset_year_ts_$cleanSchoolId', cloudBest.toIso8601String());
      }
    } catch (_) {}

    return localResetTs;
  }

  Future<Set<String>> _getSchoolSubjectIds(String schoolId) async {
    final cleanSchoolId = AppConstants.sanitizeSchoolId(schoolId);
    final Set<String> subjectIds = {};
    try {
      final classes = await getClasses(cleanSchoolId);
      for (final c in classes) {
        final subs = await getSubjects(c.id);
        for (final s in subs) {
          subjectIds.add(s.id);
        }
      }
      if (classes.isNotEmpty) {
        final classIds = classes.map((c) => c.id).toList();
        final dbSubs = await _supabase
            .from(AppTables.subjects)
            .select('id')
            .inFilter('class_id', classIds);
        for (final row in (dbSubs as List)) {
          final id = row['id']?.toString();
          if (id != null && id.isNotEmpty) {
            subjectIds.add(id);
          }
        }
      }
    } catch (_) {}
    return subjectIds;
  }

  // Get active and expired/completed homework counts for Teacher Dashboard
  // Teacher completion depends ONLY on whether the homework's deadline time has expired (not single student completion!)
  Future<Map<String, int>> getDashboardHomeworkStats([String? schoolId]) async {
    String cleanSchoolId = AppConstants.defaultSchoolId;
    try {
      final prefs = await SharedPreferences.getInstance();
      cleanSchoolId = AppConstants.sanitizeSchoolId(
        schoolId ?? prefs.getString(AppConstants.keySchoolCode),
      );
    } catch (_) {}

    final schoolSubjectIds = await _getSchoolSubjectIds(cleanSchoolId);
    final resetTs = await _getSchoolResetTimestamp(cleanSchoolId);
    final Map<String, Homework> allHomeworks = {};

    try {
      final hwRes = await _supabase
          .from(AppTables.homework)
          .select()
          .eq('is_deleted', false);
      for (final e in (hwRes as List)) {
        final hw = Homework.fromJson(Map<String, dynamic>.from(e as Map));
        if (schoolSubjectIds.contains(hw.subjectId) &&
            (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs))) {
          allHomeworks[hw.id] = hw;
        }
      }
    } catch (_) {}

    try {
      final sysRows = await _supabase
          .from(AppTables.announcements)
          .select('content')
          .like('title', '$_sysHomeworkPrefix%')
          .order('created_at', ascending: false)
          .limit(25);
      for (final row in (sysRows as List)) {
        final raw = row['content'] as String?;
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          for (final e in list) {
            final hw = Homework.fromJson(Map<String, dynamic>.from(e as Map));
            if (!hw.isDeleted &&
                schoolSubjectIds.contains(hw.subjectId) &&
                (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs))) {
              allHomeworks[hw.id] = hw;
            }
          }
        }
      }
    } catch (_) {}

    int activeCount = 0;
    int completedCount = 0;
    for (final hw in allHomeworks.values) {
      if (hw.isExpired || !hw.isCurrent) {
        completedCount++;
      } else {
        activeCount++;
      }
    }

    return {
      'active': activeCount,
      'completed': completedCount,
    };
  }

  // Get all expired/completed homework items across subjects for Teacher Dashboard
  Future<List<Homework>> getAllCompletedHomework([String? schoolId]) async {
    String cleanSchoolId = AppConstants.defaultSchoolId;
    try {
      final prefs = await SharedPreferences.getInstance();
      cleanSchoolId = AppConstants.sanitizeSchoolId(
        schoolId ?? prefs.getString(AppConstants.keySchoolCode),
      );
    } catch (_) {}

    final schoolSubjectIds = await _getSchoolSubjectIds(cleanSchoolId);
    final resetTs = await _getSchoolResetTimestamp(cleanSchoolId);
    final Map<String, Homework> completed = {};

    try {
      final hwRes = await _supabase
          .from(AppTables.homework)
          .select()
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      for (final e in (hwRes as List)) {
        final hw = Homework.fromJson(Map<String, dynamic>.from(e as Map));
        if (schoolSubjectIds.contains(hw.subjectId) &&
            (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs)) &&
            (hw.isExpired || !hw.isCurrent)) {
          completed[hw.id] = hw;
        }
      }
    } catch (_) {}

    try {
      final sysRows = await _supabase
          .from(AppTables.announcements)
          .select('content')
          .like('title', '$_sysHomeworkPrefix%')
          .order('created_at', ascending: false)
          .limit(25);
      for (final row in (sysRows as List)) {
        final raw = row['content'] as String?;
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          for (final e in list) {
            final hw = Homework.fromJson(Map<String, dynamic>.from(e as Map));
            if (!hw.isDeleted &&
                schoolSubjectIds.contains(hw.subjectId) &&
                (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs)) &&
                (hw.isExpired || !hw.isCurrent)) {
              completed[hw.id] = hw;
            }
          }
        }
      }
    } catch (_) {}

    final list = completed.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Get all active homework items across subjects for Teacher Dashboard
  Future<List<Homework>> getAllActiveHomework([String? schoolId]) async {
    String cleanSchoolId = AppConstants.defaultSchoolId;
    try {
      final prefs = await SharedPreferences.getInstance();
      cleanSchoolId = AppConstants.sanitizeSchoolId(
        schoolId ?? prefs.getString(AppConstants.keySchoolCode),
      );
    } catch (_) {}

    final schoolSubjectIds = await _getSchoolSubjectIds(cleanSchoolId);
    final resetTs = await _getSchoolResetTimestamp(cleanSchoolId);
    final Map<String, Homework> active = {};

    try {
      final hwRes = await _supabase
          .from(AppTables.homework)
          .select()
          .eq('is_deleted', false)
          .eq('is_current', true)
          .order('created_at', ascending: false);
      for (final e in (hwRes as List)) {
        final hw = Homework.fromJson(Map<String, dynamic>.from(e as Map));
        if (schoolSubjectIds.contains(hw.subjectId) &&
            (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs)) &&
            !hw.isExpired) {
          active[hw.id] = hw;
        }
      }
    } catch (_) {}

    try {
      final sysRows = await _supabase
          .from(AppTables.announcements)
          .select('content')
          .like('title', '$_sysHomeworkPrefix%')
          .order('created_at', ascending: false)
          .limit(25);
      for (final row in (sysRows as List)) {
        final raw = row['content'] as String?;
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          for (final e in list) {
            final hw = Homework.fromJson(Map<String, dynamic>.from(e as Map));
            if (!hw.isDeleted &&
                hw.isCurrent &&
                !hw.isExpired &&
                schoolSubjectIds.contains(hw.subjectId) &&
                (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs))) {
              active[hw.id] = hw;
            }
          }
        }
      }
    } catch (_) {}

    final list = active.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Load fallback homework list for custom subjects
  Future<List<Homework>> _getFallbackHomeworkForSubject(String subjectId) async {
    final Map<String, Homework> merged = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_localHomeworkKeyPrefix$subjectId');
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          final hw = Homework.fromJson(e as Map<String, dynamic>);
          merged[hw.id] = hw;
        }
      }
    } catch (_) {}

    try {
      final sysTitle = '$_sysHomeworkPrefix$subjectId';
      final sysRows = await _supabase
          .from(AppTables.announcements)
          .select('content')
          .eq('title', sysTitle)
          .order('created_at', ascending: false)
          .limit(1);

      if ((sysRows as List).isNotEmpty) {
        final raw = sysRows.first['content'] as String?;
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List;
          for (final e in list) {
            final hw = Homework.fromJson(e as Map<String, dynamic>);
            merged[hw.id] = hw;
          }
        }
      }
    } catch (_) {}

    return merged.values.toList();
  }

  Future<void> _saveFallbackHomeworkForSubject(String subjectId, List<Homework> list) async {
    final jsonStr = jsonEncode(list.map((h) => h.toJson()).toList());
    String schoolId = AppConstants.defaultSchoolId;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_localHomeworkKeyPrefix$subjectId', jsonStr);
      schoolId = AppConstants.sanitizeSchoolId(prefs.getString(AppConstants.keySchoolCode));
    } catch (_) {}

    try {
      final sysTitle = '$_sysHomeworkPrefix$subjectId';
      await _supabase.from(AppTables.announcements).insert({
        'id': const Uuid().v4(),
        'school_id': schoolId,
        'title': sysTitle,
        'content': jsonStr,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'priority': false,
        'is_deleted': false,
      });
    } catch (_) {}
  }

  // Fetch today's homework for Student ('تحضير اليوم')
  // Shows homeworks not yet completed by this student (if time expired without completion, HomeworkCard shows 'انتهى وقت الواجب')
  Future<List<Homework>> getCurrentHomework(String subjectId) async {
    final Map<String, Homework> merged = {};
    final studentCompletedIds = await getStudentCompletedHomeworkIds();
    final resetTs = await _getSchoolResetTimestamp();

    try {
      final res = await _supabase
          .from(AppTables.homework)
          .select()
          .eq('subject_id', subjectId)
          .eq('is_current', true)
          .eq('is_deleted', false);
      for (final e in (res as List)) {
        final hw = Homework.fromJson(e as Map<String, dynamic>);
        if (!studentCompletedIds.contains(hw.id) &&
            (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs))) {
          merged[hw.id] = hw;
        }
      }
    } catch (_) {}

    final fallback = await _getFallbackHomeworkForSubject(subjectId);
    for (final hw in fallback) {
      if (hw.isCurrent &&
          !hw.isDeleted &&
          !studentCompletedIds.contains(hw.id) &&
          (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs))) {
        merged[hw.id] = hw;
      }
    }

    final list = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Get active homework for a subject with safe fallback
  Stream<List<Homework>> watchCurrentHomework(String subjectId) async* {
    yield await getCurrentHomework(subjectId);
  }

  // Fetch completed & expired homework for Student ('مكتمل')
  Future<List<Homework>> getHomeworkArchive(String subjectId) async {
    final Map<String, Homework> merged = {};
    final studentCompletedIds = await getStudentCompletedHomeworkIds();
    final resetTs = await _getSchoolResetTimestamp();

    try {
      final res = await _supabase
          .from(AppTables.homework)
          .select()
          .eq('subject_id', subjectId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      for (final e in (res as List)) {
        final hw = Homework.fromJson(e as Map<String, dynamic>);
        if ((resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs)) &&
            (!hw.isCurrent || hw.isExpired || studentCompletedIds.contains(hw.id))) {
          merged[hw.id] = hw;
        }
      }
    } catch (_) {}

    final fallback = await _getFallbackHomeworkForSubject(subjectId);
    for (final hw in fallback) {
      if (!hw.isDeleted &&
          (resetTs == null || !hw.createdAt.toUtc().isBefore(resetTs)) &&
          (!hw.isCurrent || hw.isExpired || studentCompletedIds.contains(hw.id))) {
        merged[hw.id] = hw;
      }
    }

    final list = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Get homework archive with safe fallback
  Stream<List<Homework>> watchHomeworkArchive(String subjectId) async* {
    yield await getHomeworkArchive(subjectId);
  }

  // Add homework (Teacher)
  Future<void> addHomework(Homework homework) async {
    try {
      await _supabase.from(AppTables.homework).insert(homework.toJson());
      return;
    } catch (e) {
      if (e.toString().contains('deadline') || e.toString().contains('PGRST204')) {
        try {
          // Fallback if 'deadline' column is not in DB table
          final data = homework.toJson()..remove('deadline');
          if (homework.deadline != null) {
            final fullDeadlineStr = ArabicDayHelper.formatFullDayDateTime(homework.deadline!);
            data['description'] = '${homework.description}\n\n📅 موعد التسليم: $fullDeadlineStr';
          }
          await _supabase.from(AppTables.homework).insert(data);
          return;
        } catch (innerError) {
          debugPrint('[HomeworkService] Fallback homework insert notice: $innerError');
        }
      }
    }

    // Fallback for custom subjects not in 'subjects' table (FK 23503) or RLS
    final existing = await _getFallbackHomeworkForSubject(homework.subjectId);
    existing.add(homework);
    await _saveFallbackHomeworkForSubject(homework.subjectId, existing);
  }

  // Mark homework as completed locally for THIS student only (does NOT mark completed for Teacher or other students)
  Future<void> archiveHomework(String id, {String? subjectId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schoolId = AppConstants.sanitizeSchoolId(prefs.getString(AppConstants.keySchoolCode));
      final completed = await getStudentCompletedHomeworkIds(schoolId);
      completed.add(id);
      await prefs.setStringList('${_archivedHomeworkIdsKey}_$schoolId', completed.toList());
    } catch (_) {}
  }

  // Reset all homework, archives, and announcements for a school (Start New Academic Year)
  Future<void> resetSchoolAcademicYear(String schoolId) async {
    final cleanSchoolId = AppConstants.sanitizeSchoolId(schoolId);
    final nowUtc = DateTime.now().toUtc();
    final schoolSubjectIds = await _getSchoolSubjectIds(cleanSchoolId);

    // 1. Save reset timestamp locally and in cloud so any older homework/announcements are immediately hidden
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reset_year_ts_$cleanSchoolId', nowUtc.toIso8601String());
      await prefs.remove('${_archivedHomeworkIdsKey}_$cleanSchoolId');
      if (cleanSchoolId == AppConstants.defaultSchoolId) {
        await prefs.remove(_archivedHomeworkIdsKey);
      }
      for (final subId in schoolSubjectIds) {
        await prefs.remove('$_localHomeworkKeyPrefix$subId');
      }
    } catch (_) {}

    try {
      await _supabase.from(AppTables.announcements).insert({
        'id': const Uuid().v4(),
        'school_id': cleanSchoolId,
        'title': '$_sysResetYearPrefix$cleanSchoolId',
        'content': nowUtc.toIso8601String(),
        'created_at': nowUtc.toIso8601String(),
        'priority': false,
        'is_deleted': false,
      });
    } catch (_) {}

    // 2. Also attempt to soft-delete / delete rows in DB if permitted by RLS
    if (schoolSubjectIds.isNotEmpty) {
      try {
        await _supabase
            .from(AppTables.homework)
            .update({'is_deleted': true})
            .inFilter('subject_id', schoolSubjectIds.toList());
      } catch (_) {}
      try {
        await _supabase
            .from(AppTables.homework)
            .delete()
            .inFilter('subject_id', schoolSubjectIds.toList());
      } catch (_) {}
    }
  }

  // Delete homework (Soft delete in DB and purge from fallback / local storage)
  Future<void> deleteHomework(String id, {String? subjectId}) async {
    try {
      await _supabase.from(AppTables.homework).update({'is_deleted': true}).eq('id', id);
    } catch (e) {
      debugPrint('[HomeworkService] deleteHomework DB notice: $e');
    }

    if (subjectId != null && subjectId.isNotEmpty) {
      try {
        final existing = await _getFallbackHomeworkForSubject(subjectId);
        final updated = existing.where((h) => h.id != id).toList();
        await _saveFallbackHomeworkForSubject(subjectId, updated);
      } catch (_) {}
    }
  }
}