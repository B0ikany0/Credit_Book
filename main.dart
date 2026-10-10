import 'package:flutter/material.dart';

import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CreditBook',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0C1C3D),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E2C75)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
