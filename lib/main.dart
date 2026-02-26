import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ledger/firebase_options.dart';

// Theme
import 'theme/app_theme.dart';

// Providers
import 'providers/expense_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/analytics_provider.dart';

// Screens
import 'screens/main_navigation.dart';
import 'FrontEnd/Auth/SplashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392, 825),
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LEDGER',
          theme: AppTheme.light,
          home: const _AuthGate(),
          routes: {
            '/SplashScreen': (context) => const Splashscreen(),
            '/Home': (context) => const MainNavigation(),
          },
        ),
      ),
    );
  }
}

// Auth gate
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.bg,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
          );
        }
        if (snap.hasData && snap.data != null) {
          return const MainNavigation();
        }
        return const Splashscreen();
      },
    );
  }
}
