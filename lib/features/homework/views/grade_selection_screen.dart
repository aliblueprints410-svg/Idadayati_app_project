import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/school_class.dart';
import '../providers/homework_providers.dart';
import 'main_screen.dart';

class GradeSelectionScreen extends ConsumerStatefulWidget {
  final String? departmentFilter;
  final bool showDepartments;

  const GradeSelectionScreen({
    super.key,
    this.departmentFilter,
    this.showDepartments = true,
  });

  @override
  ConsumerState<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends ConsumerState<GradeSelectionScreen> {
  String _selectedDepartment = 'ميكانيك';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.departmentFilter != null && widget.departmentFilter!.isNotEmpty) {
      _selectedDepartment = widget.departmentFilter!;
    }
  }

  static const List<Map<String, dynamic>> _vocationalDepartments = [
    {'name': 'ميكانيك', 'icon': Icons.precision_manufacturing_rounded, 'color': Color(0xFFB45309)},
    {'name': 'أمن سيبراني', 'icon': Icons.security_rounded, 'color': Color(0xFF1E40AF)},
    {'name': 'نجارة', 'icon': Icons.carpenter_rounded, 'color': Color(0xFF854D0E)},
    {'name': 'بناء', 'icon': Icons.architecture_rounded, 'color': Color(0xFF047857)},
    {'name': 'حاسوب', 'icon': Icons.computer_rounded, 'color': Color(0xFF2563EB)},
    {'name': 'تكييف', 'icon': Icons.ac_unit_rounded, 'color': Color(0xFF0F766E)},
    {'name': 'تكرير نفط', 'icon': Icons.factory_rounded, 'color': Color(0xFF475569)},
    {'name': 'لحام', 'icon': Icons.hardware_rounded, 'color': Color(0xFFDC2626)},
    {'name': 'بتروكيمياوي', 'icon': Icons.science_rounded, 'color': Color(0xFF7C3AED)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectClass(SchoolClass schoolClass) async {
    final localStorage = ref.read(localStorageServiceProvider);
    await localStorage.saveSelectedGrade(schoolClass.id);
    await localStorage.saveSelectedGradeName(schoolClass.name);

    if (schoolClass.name.contains(' - ')) {
      final dept = schoolClass.name.split(' - ').sublist(1).join(' - ').trim();
      await localStorage.saveSelectedDepartment(dept);
    }

    final currentSchoolId = localStorage.getSchoolCode();
    if (currentSchoolId != null && currentSchoolId.isNotEmpty) {
      await ref.read(notificationServiceProvider).subscribeToClass(
            schoolCode: currentSchoolId,
            classId: schoolClass.id,
          );
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localStorage = ref.watch(localStorageServiceProvider);
    final schoolId = localStorage.getSchoolCode();
    final activeSchool = ref.watch(activeSchoolProvider).valueOrNull;
    final schoolName = activeSchool?.name ?? localStorage.getSchoolName() ?? AppConstants.kirkukVocSchoolName;
    final hPadding = Responsive.getHorizontalPadding(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVocational = activeSchool?.isVocational ?? (schoolName.contains('مهن') || schoolName.contains('صناع'));
    final isLockedToDepartment = isVocational && widget.departmentFilter != null && widget.departmentFilter!.isNotEmpty;
    final currentDepartment = isLockedToDepartment ? widget.departmentFilter! : _selectedDepartment;

    if (schoolId == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: const Center(child: Text('تنبيه: يرجى تسجيل الدخول أولاً')),
      );
    }

    final classesAsync = ref.watch(classesProvider(schoolId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLockedToDepartment
                  ? 'تغيير المرحلة'
                  : (isVocational ? 'اختيار القسم والمرحلة' : 'اختيار الصف الدراسي'),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isDark ? Colors.white : AppColors.primary),
            ),
            Text(
              isLockedToDepartment
                  ? currentDepartment
                  : (schoolName.isNotEmpty ? '$schoolName • ${activeSchool?.typeLabel ?? ""}' : ''),
              style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Luxury Card
                Padding(
                  padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.borderGold,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkGoldSurface : AppColors.goldSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLockedToDepartment ? 'تغيير المرحلة الدراسية ✨' : 'مرحباً بك في تطبيق طالب ✨',
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.primary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isVocational
                                    ? (isLockedToDepartment
                                        ? 'قسم: $currentDepartment • اختر مرحلتك لعرض المواد'
                                        : 'حدد قسمك وتخصصك المهني لعرض المواد والجداول والواجبات')
                                    : 'اختر صفك الدراسي لعرض المواد والواجبات والجدول الأسبوعي',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قسم أو صف (مثال: كهرباء، ثالث مهني)...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // Horizontal Department Filter Chips (Shown only for Vocational schools)
                if (isVocational && widget.showDepartments && !isLockedToDepartment)
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 4),
                      itemCount: _vocationalDepartments.length,
                      itemBuilder: (context, index) {
                        final dept = _vocationalDepartments[index];
                        final isSelected = _selectedDepartment == dept['name'];
                        final Color deptColor = dept['color'];

                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FilterChip(
                            avatar: Icon(
                              dept['icon'],
                              size: 16,
                              color: isSelected ? Colors.white : deptColor,
                            ),
                            label: Text(dept['name']),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedDepartment = dept['name'];
                              });
                            },
                            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border),
                                width: 1.2,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 8),

                // Classes List
                Expanded(
                  child: classesAsync.when(
                    data: (classes) {
                      // Filter by department (if vocational) and search query
                      final filtered = classes.where((c) {
                        final matchesDept = !isVocational ||
                            currentDepartment.isEmpty ||
                            c.name.contains(currentDepartment) ||
                            currentDepartment.contains(c.name.replaceAll('الأول مهني - ', '').replaceAll('الثاني مهني - ', '').replaceAll('الثالث مهني - ', ''));

                        final matchesSearch = _searchQuery.isEmpty ||
                            c.name.toLowerCase().contains(_searchQuery.toLowerCase());

                        return matchesDept && matchesSearch;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text(
                                'لا توجد صفوف تطابق البحث',
                                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDepartment = 'ميكانيك';
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                                child: const Text('إعادة تعيين البحث'),
                              ),
                            ],
                          ),
                        );
                      }

                      return AnimationLimiter(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8.0),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final schoolClass = filtered[index];
                            final isGrade12 = schoolClass.name.contains('ثالث');
                            final isGrade11 = schoolClass.name.contains('ثاني');

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 25.0,
                                child: FadeInAnimation(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isGrade12
                                            ? AppColors.borderGold
                                            : AppColors.border,
                                        width: isGrade12 ? 1.5 : 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                        if (isGrade12)
                                          BoxShadow(
                                            color: AppColors.gold.withValues(alpha: 0.06),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(18),
                                        onTap: () => _selectClass(schoolClass),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // Stage Emblem
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: isGrade12
                                                      ? AppColors.goldSurface
                                                      : (isGrade11 ? AppColors.blueSurface : AppColors.surfaceMuted),
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: isGrade12
                                                        ? AppColors.gold.withValues(alpha: 0.4)
                                                        : AppColors.primary.withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: Icon(
                                                  isGrade12
                                                      ? Icons.military_tech_rounded
                                                      : (isGrade11 ? Icons.edit_rounded : Icons.school_rounded),
                                                  color: isGrade12 ? AppColors.gold : AppColors.primary,
                                                  size: 26,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            schoolClass.name,
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w800,
                                                              color: AppColors.textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isGrade12)
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.goldSurface,
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(color: AppColors.gold),
                                                            ),
                                                            child: const Text(
                                                              'وزاري',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColors.goldDark,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    const Text(
                                                      'انقر للدخول وعرض المواد والواجبات المدرسية',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}