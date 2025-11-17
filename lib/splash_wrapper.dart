import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthService>().isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final loggedIn = snapshot.data!;

        return loggedIn ? const HomePage() : const LoginPage();
      },
    );
  }
}
