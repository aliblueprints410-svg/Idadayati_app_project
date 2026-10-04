import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/qr_code_scanner_sheet.dart';
import '../providers/auth_providers.dart';
import '../../teacher/views/teacher_dashboard_screen.dart';

class TeacherLoginScreen extends ConsumerStatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  ConsumerState<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends ConsumerState<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _scanSchoolQrCode() async {
    final scanned = await QrCodeScannerSheet.scan(context);
    if (scanned != null && scanned.trim().isNotEmpty && mounted) {
      setState(() {
        _schoolCodeController.text = scanned.trim();
      });
    }
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('teacher_email');
      final savedPassword = prefs.getString('teacher_password');
      final savedSchoolCode = prefs.getString('teacher_school_code');

      if (savedSchoolCode != null && savedSchoolCode.isNotEmpty) {
        _schoolCodeController.text = savedSchoolCode;
      }

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canCheck && savedEmail != null && savedPassword != null;
        });
      }
    } catch (_) {}
  }

  Future<void> _loginWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'يرجى تأكيد هويتك بالبصمة لتسجيل الدخول السريع',
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('teacher_email');
        final savedPassword = prefs.getString('teacher_password');
        final savedSchoolCode = prefs.getString('teacher_school_code') ?? 'KIRKUK-VOC';

        if (savedEmail != null && savedPassword != null) {
          _schoolCodeController.text = savedSchoolCode;
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          await _login();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التحقق بالبصمة: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final school = await authService.loginTeacherWithSchool(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        schoolCode: _schoolCodeController.text.trim(),
      );

      // Save credentials & bound school info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacher_email', _emailController.text.trim());
      await prefs.setString('teacher_password', _passwordController.text.trim());
      await prefs.setString('teacher_school_code', school.schoolCode);
      await prefs.setString('teacher_school_name', school.name);

      // Save active school UUID and clear any student grade selection so teacher mode is completely separate
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.clearStudentGrade();
      await localStorage.saveSchoolCode(school.id);
      await localStorage.saveSchoolName(school.name);
      await localStorage.saveSchoolShortCode(school.schoolCode);
      ref.invalidate(activeSchoolProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('أهلاً بك في إدارة: ${school.name}')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final cleanError = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cleanError),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'بوابة الأساتذة والإدارة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.darkTextPrimary : AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Icon
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, size: 44, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'تسجيل دخول الكادر التدريسي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل كود إعداديتك المهنية وبيانات حسابك لإدارة الأقسام والواجبات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick fill shortcut for Kirkuk Vocational
                  InkWell(
                    onTap: () {
                      setState(() {
                        _schoolCodeController.text = 'KIRKUK-VOC';
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.goldSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGold, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app_rounded, color: AppColors.goldDark, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تعبئة كود إعدادية كركوك المهنية (KIRKUK-VOC)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.goldDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // School Code
                  Text(
                    'كود الإعدادية الخاص',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _schoolCodeController,
                    decoration: InputDecoration(
                      hintText: 'مثال: KIRKUK-VOC',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _scanSchoolQrCode,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال كود الإعدادية الخاص بك';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  Text(
                    'البريد الإلكتروني للتدريسي',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'teacher@kirkuk-voc.edu',
                      prefixIcon: Icon(Icons.email_outlined, color: isDark ? AppColors.primaryLight : AppColors.primary),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty || !val.contains('@')) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Text(
                    'كلمة المرور',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: isDark ? AppColors.primaryLight : AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppColors.primary,
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'تسجيل الدخول للكادر',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),

                  // Biometric Button
                  if (_canCheckBiometrics) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _loginWithBiometrics,
                      icon: const Icon(Icons.fingerprint_rounded, color: AppColors.goldDark),
                      label: const Text('تسجيل الدخول السريع بالبصمة'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Privacy / Isolation Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security_rounded, size: 18, color: AppColors.primaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'نظام تسجيل دخول مستقل ومخصص للتعليم الإعدادي والمهني، منفصل تماماً عن المنظومات العامة.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}