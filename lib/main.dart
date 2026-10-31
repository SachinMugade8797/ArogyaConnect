import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/database/app_database.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/doctor/doctor_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database with full schema and seed data
  await AppDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: ArogyaNexusApp(),
    ),
  );
}

class ArogyaNexusApp extends ConsumerWidget {
  const ArogyaNexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    Widget homeScreen;
    if (authState.isLoading) {
      homeScreen = const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary600)),
      );
    } else if (!authState.isAuthenticated) {
      homeScreen = const OnboardingScreen();
    } else if (authState.isDoctor) {
      homeScreen = const DoctorNavigationScreen();
    } else {
      homeScreen = const MainNavigationScreen();
    }

    return MaterialApp(
      title: 'ArogyaNexus Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary600,
          primary: AppColors.primary600,
          secondary: AppColors.accent600,
          surface: AppColors.slate50,
        ),
        scaffoldBackgroundColor: AppColors.slate50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.slate200),
          ),
        ),
      ),
      home: homeScreen,
    );
  }
}
