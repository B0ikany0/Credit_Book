import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/form_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? _demoOtp;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get _passwordValid =>
      passwordRules(passwordController.text).every((rule) => rule.isValid);

  bool get _canReset =>
      _demoOtp != null &&
      otpController.text == _demoOtp &&
      _passwordValid &&
      passwordController.text == confirmPasswordController.text;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      phoneController,
      otpController,
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
      phoneController,
      otpController,
      passwordController,
      confirmPasswordController,
    ]) {
      controller.removeListener(_handleFormChanged);
    }
    phoneController.dispose();
    otpController.dispose();
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
                  borderRadius: BorderRadius.circular(28),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF0E2C75),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
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
                              'Reset Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: compact ? 26 : 38,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Phone Number',
                      style: TextStyle(fontSize: compact ? 19 : 24),
                    ),
                    const SizedBox(height: 8),
                    RoundedInput(
                      controller: phoneController,
                      hintText: 'Enter your phone number',
                      obscureText: false,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton.icon(
                        onPressed: _requestOtp,
                        icon: const Icon(Icons.sms_outlined),
                        label: const Text('Send OTP'),
                      ),
                    ),
                    if (_demoOtp != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4D6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Demo OTP: $_demoOtp. No SMS was sent; connect an OTP provider for real delivery.',
                          style: const TextStyle(color: Color(0xFF5D4700)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'One-time code',
                        style: TextStyle(fontSize: compact ? 19 : 24),
                      ),
                      const SizedBox(height: 8),
                      RoundedInput(
                        controller: otpController,
                        hintText: 'Enter 6-digit code',
                        obscureText: false,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'New Password',
                        style: TextStyle(fontSize: compact ? 19 : 24),
                      ),
                      const SizedBox(height: 8),
                      RoundedInput(
                        controller: passwordController,
                        hintText: 'New password',
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
                      const SizedBox(height: 12),
                      ...passwordRules(passwordController.text).map(
                        (rule) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                rule.isValid
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 16,
                                color: rule.isValid
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(rule.label)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: compact ? 19 : 24),
                      ),
                      const SizedBox(height: 8),
                      RoundedInput(
                        controller: confirmPasswordController,
                        hintText: 'Confirm new password',
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: ElevatedButton(
                          onPressed: _canReset ? _resetPassword : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C1D79),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reset Password'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _requestOtp() {
    final digits = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number first.')),
      );
      return;
    }

    if (!kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP delivery is not configured for this app yet.'),
        ),
      );
      return;
    }

    final code = Random.secure().nextInt(1000000).toString().padLeft(6, '0');
    setState(() => _demoOtp = code);
  }

  void _resetPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset demo complete. Connect authentication to save it.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}
