import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import 'onboarding_screen.dart';
import '../../homework/views/grade_selection_screen.dart';
import '../../homework/views/main_screen.dart';
import '../../teacher/views/teacher_dashboard_screen.dart';
import '../../onboarding/views/intro_walkthrough_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Request push notification permission safely once activity is displayed
    try {
      await ref.read(notificationServiceProvider).requestPermission();
    } catch (_) {}

    // Elegant delay so user enjoys the splash transition
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    try {
      final localStorage = ref.read(localStorageServiceProvider);

      // Check if Teacher is logged in
      try {
        final supabaseAuth = ref.read(supabaseClientProvider).auth;
        if (supabaseAuth.currentUser != null) {
          final metaSchoolId = supabaseAuth.currentUser!.userMetadata?['school_id']?.toString();
          if (metaSchoolId != null && metaSchoolId.isNotEmpty) {
            await localStorage.saveSchoolCode(metaSchoolId);
          }
          if (!mounted) return;
          _navigate(const TeacherDashboardScreen());
          return;
        }
      } catch (_) {}

      // Check if Student has already set school code
      final schoolCode = localStorage.getSchoolCode();

      if (schoolCode != null && schoolCode.isNotEmpty) {
        final gradeId = localStorage.getSelectedGrade();
        try {
          ref.read(notificationServiceProvider).subscribeToSchool(schoolCode, classId: gradeId);
        } catch (_) {}
        if (gradeId != null && gradeId.isNotEmpty) {
          _navigate(const MainScreen());
        } else {
          _navigate(const GradeSelectionScreen());
        }
      } else {
        final prefs = ref.read(sharedPreferencesProvider);
        final hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;

        if (hasSeenIntro) {
          _navigate(const OnboardingScreen());
        } else {
          _navigate(const IntroWalkthroughScreen());
        }
      }
    } catch (_) {
      if (mounted) {
        _navigate(const OnboardingScreen());
      }
    }
  }

  void _navigate(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Glowing App Emblem
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient Subtle Gold & Blue Glow Rings
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.06),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.10),
                        ),
                      ),
                      // Core Icon Card with Gold & Blue Accent Border
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Title and Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.goldSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 16, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text(
                            AppConstants.appTagline,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Elegant bottom progress indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'جاري الاتصال بالنظام...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
