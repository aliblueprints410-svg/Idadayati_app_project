import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'subjects_tab.dart';
import '../../announcements/views/announcements_tab.dart';
import '../../schedule/views/schedule_tab.dart';
import '../../settings/views/settings_tab.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const SubjectsTab(),
    const ScheduleTab(),
    const AnnouncementsTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: _buildNavItem(0, Icons.menu_book_rounded, Icons.menu_book_outlined, 'المواد', isDark)),
                    Expanded(child: _buildNavItem(1, Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'الجدول', isDark)),
                    Expanded(child: _buildNavItem(2, Icons.campaign_rounded, Icons.campaign_outlined, 'التبليغات', isDark)),
                    Expanded(child: _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'الإعدادات', isDark)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryLight.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.09))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: isDark ? AppColors.gold : AppColors.borderGold, width: 1.0)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 24,
              color: isSelected
                  ? (isDark ? AppColors.goldLight : AppColors.primary)
                  : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.goldLight : AppColors.primary)
                    : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}