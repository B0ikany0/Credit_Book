import 'package:flutter/material.dart';

import '../widgets/credit_book_brand_header.dart';
import '../widgets/form_widgets.dart';
import 'create_account_page.dart';
import 'dashboard_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool get isPasswordValid =>
      passwordRules(passwordController.text).every((rule) => rule.isValid);

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_handleCredentialsChanged);
    passwordController.addListener(_handleCredentialsChanged);
  }

  void _handleCredentialsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    usernameController.removeListener(_handleCredentialsChanged);
    passwordController.removeListener(_handleCredentialsChanged);
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C3D),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 18 : 32,
                  vertical: compact ? 20 : 30,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF0D1D45), width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    CreditBookBrandHeader(compact: compact),
                    SizedBox(height: compact ? 30 : 42),
                    Text(
                      'Username',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: usernameController,
                      hintText: 'Enter username',
                      obscureText: false,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: passwordController,
                      hintText: 'Enter password',
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        tooltip: _isPasswordVisible
                            ? 'Hide password'
                            : 'Show password',
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: passwordController,
                      builder: (context, value, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: passwordRules(value.text).map((rule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    rule.isValid
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 17,
                                    color: rule.isValid
                                        ? Colors.green
                                        : const Color(0xFF5A5A5A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rule.label,
                                      style: TextStyle(
                                        fontSize: compact ? 14 : 16,
                                        color: const Color(0xFF3F3F3F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: compact ? 17 : 22,
                            color: const Color(0xFF0B2F86),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed:
                            usernameController.text.trim().isNotEmpty &&
                                isPasswordValid
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardPage(
                                      ownerName: 'Bontle Molefe',
                                      businessName: 'BB Market',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C1D79),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: compact ? 22 : 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountPage(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: compact ? 16 : 22,
                              color: const Color(0xFF181818),
                            ),
                            children: const [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Create account',
                                style: TextStyle(
                                  color: Color(0xFF0B2F86),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
