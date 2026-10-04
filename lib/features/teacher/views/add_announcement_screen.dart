import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../announcements/models/announcement.dart';
import '../../announcements/providers/announcement_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../homework/providers/homework_providers.dart';
import 'teacher_dashboard_screen.dart';

class AddAnnouncementScreen extends ConsumerStatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  ConsumerState<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends ConsumerState<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPriority = false;
  bool _isLoading = false;

  // Targeting fields
  String _targetScope = 'all'; // 'all' (عام) or 'specific' (مخصص)
  String _vocationalStage = 'الكل';
  String _vocationalDept = 'الكل';
  String _academicClass = 'الكل';

  static const List<String> _vocationalStages = [
    'الكل',
    'الصف الأول المهني',
    'الصف الثاني المهني',
    'الصف الثالث المهني',
  ];

  static const List<String> _vocationalDepts = [
    'الكل',
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _buildTargetText({required bool isVocational}) {
    if (_targetScope == 'all') {
      return 'عام لكافة طلاب المدرسة';
    }
    if (isVocational) {
      if (_vocationalStage == 'الكل' && _vocationalDept == 'الكل') {
        return 'عام لكافة طلاب وأقسام المدرسة';
      } else if (_vocationalStage != 'الكل' && _vocationalDept == 'الكل') {
        return '$_vocationalStage (كافة الأقسام)';
      } else if (_vocationalStage == 'الكل' && _vocationalDept != 'الكل') {
        return 'قسم $_vocationalDept (كافة الصفوف)';
      } else {
        return '$_vocationalStage - قسم $_vocationalDept';
      }
    } else {
      if (_academicClass == 'الكل') {
        return 'عام لكافة الصفوف';
      }
      return _academicClass;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final localStorage = ref.read(localStorageServiceProvider);
      final schoolId = AppConstants.sanitizeSchoolId(localStorage.getSchoolCode());
      final activeSchool = ref.read(activeSchoolProvider).valueOrNull;
      final schoolName = activeSchool?.name ?? localStorage.getSchoolName() ?? AppConstants.kirkukVocSchoolName;
      final isVocational = activeSchool?.isVocational ?? (schoolName.contains('مهن') || schoolName.contains('صناع'));

      final targetText = _buildTargetText(isVocational: isVocational);
      final rawContent = _contentController.text.trim();
      final formattedContent = _targetScope == 'all' && targetText.startsWith('عام')
          ? rawContent
          : '📌 موجه إلى: $targetText\n\n$rawContent';

      final announcement = Announcement(
        id: const Uuid().v4(),
        schoolId: schoolId,
        title: _titleController.text.trim(),
        content: formattedContent,
        createdAt: DateTime.now(),
        priority: _isPriority,
        isDeleted: false,
      );

      await ref.read(announcementServiceProvider).addAnnouncement(announcement);
      ref.invalidate(announcementsProvider(schoolId));
      ref.invalidate(teacherStatsProvider);

      // Send Push Notification
      try {
        await ref.read(notificationServiceProvider).sendPushNotification(
          schoolCode: schoolId,
          title: _isPriority
              ? '🚨 [إلى: $targetText] ${_titleController.text.trim()}'
              : '📢 [إلى: $targetText] ${_titleController.text.trim()}',
          message: rawContent,
          additionalData: {
            'type': 'announcement',
            'target': targetText,
          },
        );
      } catch (_) {}

      if (!mounted) return;
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _isPriority = false;
        _targetScope = 'all';
        _vocationalStage = 'الكل';
        _vocationalDept = 'الكل';
        _academicClass = 'الكل';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('تم نشر الإعلان بنجاح ($targetText)'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء النشر: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnnouncement(Announcement ann, String schoolId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف التبليغ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف التبليغ "${ann.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(announcementServiceProvider).deleteAnnouncement(ann.id, schoolId: schoolId);
      ref.invalidate(announcementsProvider(schoolId));
      ref.invalidate(teacherStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التبليغ بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localStorage = ref.watch(localStorageServiceProvider);
    final schoolId = AppConstants.sanitizeSchoolId(localStorage.getSchoolCode());
    final activeSchool = ref.watch(activeSchoolProvider).valueOrNull;
    final schoolName = activeSchool?.name ?? localStorage.getSchoolName() ?? AppConstants.kirkukVocSchoolName;
    final isVocational = activeSchool?.isVocational ?? (schoolName.contains('مهن') || schoolName.contains('صناع'));

    final announcementsAsync = ref.watch(announcementsProvider(schoolId));
    final classesAsync = ref.watch(classesProvider(schoolId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('نشر وإدارة التبليغات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Targeting Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'الجمهور المستهدف للتبليغ',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Scope toggle
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ChoiceChip(
                                          label: const Center(
                                            child: Text('📢 عام للجميع', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          selected: _targetScope == 'all',
                                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                                          labelStyle: TextStyle(
                                            color: _targetScope == 'all' ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                          onSelected: (val) {
                                            if (val) setState(() => _targetScope = 'all');
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ChoiceChip(
                                          label: Center(
                                            child: Text(
                                              isVocational ? '🎯 مخصص (صف وقسم)' : '🎯 مخصص لصف',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          selected: _targetScope == 'specific',
                                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                                          labelStyle: TextStyle(
                                            color: _targetScope == 'specific' ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                          onSelected: (val) {
                                            if (val) setState(() => _targetScope = 'specific');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (_targetScope == 'specific') ...[
                                    const SizedBox(height: 16),
                                    if (isVocational) ...[
                                      // Vocational Selectors: Stage + Department
                                      Text(
                                        'حدد المرحلة الدراسية:',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: _vocationalStage,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          prefixIcon: const Icon(Icons.school_rounded, size: 20),
                                        ),
                                        items: _vocationalStages.map((stage) {
                                          return DropdownMenuItem(
                                            value: stage,
                                            child: Text(stage == 'الكل' ? 'كافة الصفوف والمراحل' : stage),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) setState(() => _vocationalStage = val);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'حدد القسم المهني:',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: _vocationalDept,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          prefixIcon: const Icon(Icons.category_rounded, size: 20),
                                        ),
                                        items: _vocationalDepts.map((dept) {
                                          return DropdownMenuItem(
                                            value: dept,
                                            child: Text(dept == 'الكل' ? 'كافة الأقسام المهنية' : dept),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) setState(() => _vocationalDept = val);
                                        },
                                      ),
                                    ] else ...[
                                      // Academic Class Selector
                                      Text(
                                        'حدد الصف الدراسي المستهدف:',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 6),
                                      classesAsync.when(
                                        data: (classes) {
                                          final options = <String>['الكل', ...classes.map((c) => c.name)];
                                          final currentVal = options.contains(_academicClass) ? _academicClass : 'الكل';
                                          return DropdownButtonFormField<String>(
                                            initialValue: currentVal,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                              prefixIcon: const Icon(Icons.class_rounded, size: 20),
                                            ),
                                            items: options.map((c) {
                                              return DropdownMenuItem(
                                                value: c,
                                                child: Text(c == 'الكل' ? 'كافة الصفوف' : c),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) setState(() => _academicClass = val);
                                            },
                                          );
                                        },
                                        loading: () => const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: LinearProgressIndicator(),
                                        ),
                                        error: (_, __) => DropdownButtonFormField<String>(
                                          initialValue: _academicClass,
                                          items: const [
                                            DropdownMenuItem(value: 'الكل', child: Text('كافة الصفوف')),
                                          ],
                                          onChanged: (val) {},
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'التوجيه: ${_buildTargetText(isVocational: isVocational)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'عنوان الإعلان',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: 'مثال: موعد الامتحانات الشهرية',
                                prefixIcon: Icon(Icons.title_rounded),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة عنوان الإعلان' : null,
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'تفاصيل التبليغ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _contentController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'اكتب نص التبليغ أو التوجيهات المدرسية هنا بالتفصيل...',
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة نص الإعلان' : null,
                            ),
                            const SizedBox(height: 20),

                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              child: SwitchListTile(
                                title: const Text('إعلان عاجل وهام', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('سيظهر مميزاً باللون الأحمر لتنبيه الطلاب وأولياء الأمور'),
                                value: _isPriority,
                                activeThumbColor: Colors.red,
                                onChanged: (val) => setState(() => _isPriority = val),
                              ),
                            ),
                            const SizedBox(height: 24),

                            ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('نشر التبليغ الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.campaign_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'التبليغات المنشورة حالياً',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      announcementsAsync.when(
                        data: (announcements) {
                          if (announcements.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: Text('لا توجد تبليغات منشورة حالياً', style: TextStyle(color: Colors.grey)),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: announcements.length,
                            itemBuilder: (context, index) {
                              final ann = announcements[index];
                              return Card(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: ann.priority
                                        ? Colors.red.withValues(alpha: 0.5)
                                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    ann.priority ? Icons.warning_amber_rounded : Icons.campaign_rounded,
                                    color: ann.priority ? Colors.red : AppColors.primary,
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (ann.targetTag != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '🎯 ${ann.targetTag}',
                                            style: const TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      Text(ann.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${DateFormat('yyyy-MM-dd • hh:mm a').format(ann.createdAt).replaceAll('AM', 'ص').replaceAll('PM', 'م')}\n${ann.cleanContent}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                    tooltip: 'حذف التبليغ',
                                    onPressed: () => _deleteAnnouncement(ann, schoolId),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                        error: (e, _) => Text('خطأ: $e'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}