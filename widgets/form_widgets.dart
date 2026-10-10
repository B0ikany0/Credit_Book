import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool compact;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 138,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(height: 1.1),
            children: [
              TextSpan(
                text: '$value\n',
                style: TextStyle(
                  fontSize: compact ? 18 : 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: title,
                style: TextStyle(
                  fontSize: compact ? 15 : 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 14 : 22,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF0F2B7A),
          ),
        ),
      ),
    );
  }
}

class RoundedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const RoundedInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: compact ? 18 : 26,
          color: const Color(0xFF1C1C1C),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: compact ? 18 : 26,
            color: Color(0xFF6F6F6F),
            fontWeight: FontWeight.w300,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class PasswordRule {
  final String label;
  final bool isValid;

  const PasswordRule({required this.label, required this.isValid});
}

List<PasswordRule> passwordRules(String value) {
  return [
    PasswordRule(label: 'At least 8 characters', isValid: value.length >= 8),
    PasswordRule(
      label: 'One uppercase letter',
      isValid: value.contains(RegExp(r'[A-Z]')),
    ),
    PasswordRule(
      label: 'One lowercase letter',
      isValid: value.contains(RegExp(r'[a-z]')),
    ),
    PasswordRule(
      label: 'One number',
      isValid: value.contains(RegExp(r'[0-9]')),
    ),
    PasswordRule(
      label: 'One special character',
      isValid: value.contains(RegExp(r'[^A-Za-z0-9]')),
    ),
  ];
}
