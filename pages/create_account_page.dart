import 'package:flutter/material.dart';

import '../widgets/form_widgets.dart';
import 'dashboard_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final businessNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreedToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get passwordsMatch =>
      passwordController.text == confirmPasswordController.text;
  bool get isPasswordValid =>
      passwordRules(passwordController.text).every((rule) => rule.isValid);
  bool get isEmailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
          .hasMatch(emailController.text.trim());
  bool get formValid =>
      fullNameController.text.trim().isNotEmpty &&
      isEmailValid &&
      businessNameController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty &&
      isPasswordValid &&
      passwordsMatch &&
      agreedToTerms;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      fullNameController,
      emailController,
      businessNameController,
      phoneController,
      passwordController,
      confirmPasswordController,
    ]) {
      controller.addListener(_handleFormChanged);
    }
  }

  void _handleFormChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in [
      fullNameController,
      emailController,
      businessNameController,
      phoneController,
      passwordController,
      confirmPasswordController,
    ]) {
      controller.removeListener(_handleFormChanged);
    }
    fullNameController.dispose();
    emailController.dispose();
    businessNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 18 : 36,
                  vertical: compact ? 20 : 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF0D1D45), width: 3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: compact ? 12 : 18,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E2C75),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).maybePop(),
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Expanded(
                            child: Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: compact ? 30 : 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: fullNameController,
                      hintText: 'Full name',
                      obscureText: false,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: emailController,
                      hintText: 'Enter email address',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Business Name',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: businessNameController,
                      hintText: 'Business name',
                      obscureText: false,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: phoneController,
                      hintText: 'Phone number',
                      obscureText: false,
                    ),
                    const SizedBox(height: 18),
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
                      hintText: 'Password',
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
                    const SizedBox(height: 14),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: passwordController,
                      builder: (context, value, _) {
                        final rules = passwordRules(value.text);
                        return Column(
                          children: rules
                              .map(
                                (rule) => Row(
                                  children: [
                                    Icon(
                                      rule.isValid ? Icons.check : Icons.close,
                                      size: 16,
                                      color: rule.isValid
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        rule.label,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF3C3C3C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: compact ? 20 : 26,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RoundedInput(
                      controller: confirmPasswordController,
                      hintText: 'Confirm password',
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        tooltip: _isConfirmPasswordVisible
                            ? 'Hide confirm password'
                            : 'Show confirm password',
                        onPressed: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    if (!passwordsMatch &&
                        confirmPasswordController.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Passwords do not match',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: agreedToTerms,
                          activeColor: const Color(0xFF0E2C75),
                          onChanged: (v) =>
                              setState(() => agreedToTerms = v ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'I agree to the POPIA terms and conditions',
                              style: TextStyle(
                                fontSize: compact ? 18 : 24,
                                color: const Color(0xFF131313)
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 74,
                      child: ElevatedButton(
                        onPressed: formValid
                            ? () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => DashboardPage(
                                      ownerName: fullNameController.text.trim(),
                                      businessName: businessNameController.text
                                          .trim(),
                                      ownerPhone: phoneController.text.trim(),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: compact ? 22 : 32,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              color: Color(0xFF1D1D1D),
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Log in',
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
