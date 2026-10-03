import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/core_providers.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/confetti_celebration.dart';
import 'features/auth/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables safely
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("dotenv loaded successfully");
  } catch (e) {
    debugPrint("Warning: could not load .env: $e");
  }

  // Fallback credentials in case .env failed to load
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlEnvKey] ?? 'https://imnqwelbgxxnegapowpu.supabase.co';
  final supabaseAnonKey = dotenv.env[AppConstants.supabaseAnonKeyEnvKey] ?? 'sb_publishable_Pf2C0cVb5IsXAWvFBYOrSQ_D09k-Ho_';

  // Initialize Supabase safely
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint("Supabase initialized successfully");
  } catch (e) {
    debugPrint("Supabase initialization error: $e");
  }

  // Initialize SharedPreferences safely
  SharedPreferences? sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
    debugPrint("SharedPreferences initialized successfully");
  } catch (e) {
    debugPrint("SharedPreferences error: $e");
  }

  // Initialize Notification Service (OneSignal) asynchronously without blocking startup
  try {
    NotificationService().initialize().catchError((err) {
      debugPrint("NotificationService async error: $err");
    });
  } catch (e) {
    debugPrint("NotificationService error: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        if (sharedPreferences != null)
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SchoolApp(),
    ),
  );
}

class SchoolApp extends ConsumerWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ConfettiCelebrationOverlay(
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
