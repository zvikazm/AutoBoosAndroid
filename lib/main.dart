import 'package:flutter/material.dart';
import 'screens/books_screen.dart';
import 'screens/login_screen.dart';
import 'services/credentials_service.dart';

void main() {
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
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final credentialsService = CredentialsService();

    return FutureBuilder<bool>(
      future: credentialsService.hasStoredCredentials(),
      builder: (context, snapshot) {
        // Show loading spinner while checking credentials
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If credentials exist, go to books screen
        if (snapshot.data == true) {
          return const BooksScreen();
        }

        // Otherwise, show login screen
        return const LoginScreen();
      },
    );
  }
}
