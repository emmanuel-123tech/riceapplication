import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/app_info_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/export_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/signup_screen.dart';
import 'services/app_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppController()..init(),
      child: const RiceApp(),
    ),
  );
}

class RiceApp extends StatelessWidget {
  const RiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfricaRice QA',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      routes: {
        '/': (_) => const RootRouter(),
        '/home': (_) => const HomeScreen(),
        '/signup': (_) => const SignupScreen(),
        '/capture': (_) => const CaptureScreen(),
        '/results': (_) => const ResultsScreen(),
        '/history': (_) => const HistoryScreen(),
        '/export': (_) => const ExportScreen(),
        '/info': (_) => const AppInfoScreen(),
        '/disclaimer': (_) => const DisclaimerScreen(forceShow: false),
      },
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    if (!app.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!app.disclaimerAccepted) return const DisclaimerScreen(forceShow: true);
    if (app.user == null) return const SignupScreen();
    return const HomeScreen();
  }
}
