import 'package:flutter/material.dart';
import 'screens/books_screen.dart';
import 'screens/login_screen.dart';
import 'screens/history_screen.dart';
import 'services/credentials_service.dart';
import 'services/notification_service.dart';
import 'services/background_task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize background task service for daily notifications at 8:00 AM
  await BackgroundTaskService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Books',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthChecker(),
        '/login': (context) => const LoginScreen(),
        '/books': (context) => const BooksScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final credentialsService = CredentialsService();
    final hasCredentials = await credentialsService.hasStoredCredentials();

    if (!mounted) return;

    // Use pushReplacement to replace the auth checker with the appropriate screen
    if (hasCredentials) {
      Navigator.of(context).pushReplacementNamed('/books');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while checking credentials
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
