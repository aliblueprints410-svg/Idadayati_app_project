import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/views/onboarding_screen.dart';

class TeacherSettingsScreen extends ConsumerStatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  ConsumerState<TeacherSettingsScreen> createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends ConsumerState<TeacherSettingsScreen> {
  String _teacherEmail = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherEmail();
  }

  Future<void> _loadTeacherEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('teacher_email') ?? '';
      if (mounted) {
        setState(() {
          _teacherEmail = email;
        });
      }
    } catch (_) {}
  }

  Future<void> _launchTelegram(BuildContext context) async {
    final Uri url = Uri.parse(AppConstants.developerTelegramUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch');
      }
    } catch (_) {
      if (!context.mounted) return;
      Clipboard.setData(const ClipboardData(text: AppConstants.developerTelegramUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم نسخ رابط التليجرام: ${AppConstants.developerTelegramUrl}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final Uri url = Uri.parse(AppConstants.developerWhatsappUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (_) {
      if (!context.mounted) return;
      Clipboard.setData(const ClipboardData(text: AppConstants.developerWhatsapp));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم نسخ رقم الواتساب: ${AppConstants.developerWhatsapp}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _launchFacebook(BuildContext context) async {
    final Uri url = Uri.parse(AppConstants.developerFacebookUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch Facebook');
      }
    } catch (_) {
      if (!context.mounted) return;
      Clipboard.setData(const ClipboardData(text: AppConstants.developerFacebookUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم نسخ رابط صفحة الفيسبوك'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('هل أنت متأكد من تسجيل الخروج من لوحة تحكم الكادر التدريسي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);

              // 1. Clear SharedPreferences
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('teacher_email');
                await prefs.remove('teacher_password');
                await prefs.remove('teacher_school_code');
                await prefs.remove('teacher_school_name');
              } catch (_) {}

              // 2. Clear LocalStorageService
              try {
                await ref.read(localStorageServiceProvider).clearSession();
              } catch (_) {}

              // 3. Supabase logout
              try {
                await ref.read(authServiceProvider).logout();
              } catch (_) {}

              ref.invalidate(activeSchoolProvider);

              // 4. Navigate cleanly
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardBoxDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.border,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0, bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final localStorage = ref.watch(localStorageServiceProvider);
    final activeSchool = ref.watch(activeSchoolProvider).valueOrNull;
    final schoolName = activeSchool?.name ?? localStorage.getSchoolName() ?? 'إعدادية كركوك المهنية';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('إعدادات حساب التدريسي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Teacher Account Emblem & School Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.admin_panel_settings_rounded, size: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schoolName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _teacherEmail.isNotEmpty ? _teacherEmail : 'حساب التدريسي المعتمد',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 14, color: AppColors.goldLight),
                                const SizedBox(width: 6),
                                const Text(
                                  'كادر تعليمي معتمد ✓',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Appearance & Theme
              _buildSectionHeader('المظهر والتخصيص', isDark),
              const SizedBox(height: 10),
              Container(
                decoration: _cardBoxDecoration(context, isDark),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.amber : Colors.blue).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? Colors.amber : Colors.blue,
                    ),
                  ),
                  title: const Text('الوضع الداكن (الليلي)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    isDark ? 'مفعل حالياً' : 'معطل حالياً',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : Colors.grey),
                  ),
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state = value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Notifications
              _buildSectionHeader('التنبيهات والإشعارات', isDark),
              const SizedBox(height: 10),
              Container(
                decoration: _cardBoxDecoration(context, isDark),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Colors.amber),
                      ),
                      title: const Text('فحص إذن الإشعارات', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        'التحقق من تفعيل التنبيهات على هذا الجهاز',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : Colors.grey),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final granted = await ref.read(notificationServiceProvider).requestPermission();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(granted ? 'إذن الإشعارات مفعل بنجاح' : 'يرجى التأكد من السماح بالإشعارات في إعدادات الهاتف'),
                              backgroundColor: granted ? AppColors.success : AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('فحص'),
                      ),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.cyan),
                      ),
                      title: const Text('إرسال إشعار فحص وتجربة', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        'إرسال تنبيه تجريبي للتأكد من ربط الهاتف بالنظام',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : Colors.grey),
                      ),
                      trailing: const Icon(Icons.touch_app_rounded, size: 20, color: Colors.cyan),
                      onTap: () async {
                        final currentSchoolId = AppConstants.sanitizeSchoolId(localStorage.getSchoolCode());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري إرسال إشعار تجريبي...'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        final success = await ref.read(notificationServiceProvider).sendTestNotification(
                          schoolCode: currentSchoolId,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'تم إرسال الإشعار بنجاح! راجع شريط التنبيهات في هاتفك.'
                                  : 'تعذر تسليم الإشعار للهاتف (تحتاج منصة OneSignal لربط مفتاح Firebase FCM).',
                            ),
                            backgroundColor: success ? AppColors.success : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Developer Info
              _buildSectionHeader('حول المطور والدعم الفني', isDark),
              const SizedBox(height: 10),
              Container(
                decoration: _cardBoxDecoration(context, isDark),
                child: Column(
                  children: [
                    // Developer Header Tile
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'ع',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.developerName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'تطوير وتصميم وبرمجة التطبيقات',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),

                    // Telegram Contact
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0088CC).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.send_rounded, color: Color(0xFF0088CC), size: 20),
                      ),
                      title: const Text('تليكرام (Telegram)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text(
                        AppConstants.developerTelegramUsername,
                        style: TextStyle(fontSize: 12, color: Color(0xFF0088CC), fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
                      onTap: () => _launchTelegram(context),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),

                    // WhatsApp Contact
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                      ),
                      title: const Text('واتساب (WhatsApp)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text(
                        AppConstants.developerWhatsapp,
                        style: TextStyle(fontSize: 13, color: Color(0xFF25D366), fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
                      onTap: () => _launchWhatsApp(context),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),

                    // Facebook Contact
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.public_rounded, color: Color(0xFF1877F2), size: 20),
                      ),
                      title: const Text('فيسبوك (Facebook)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text(
                        'صفحة المطور الرسمية على فيسبوك',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1877F2), fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
                      onTap: () => _launchFacebook(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Logout Button
              OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text(
                  'تسجيل الخروج من لوحة التحكم',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.red.shade200, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.red.withValues(alpha: 0.04),
                ),
              ),
              const SizedBox(height: 24),

              // Version Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'منظومة مدرستي المهنية • الإصدار ${AppConstants.appVersion}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
