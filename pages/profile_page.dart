import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'help_feedback_page.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  final String ownerName;
  final String businessName;
  final String ownerPhone;

  const ProfilePage({
    super.key,
    required this.ownerName,
    required this.businessName,
    required this.ownerPhone,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  bool _isPickingPhoto = false;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final initial = widget.ownerName.trim().isEmpty
        ? 'U'
        : widget.ownerName.trim().characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF171927),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              margin: EdgeInsets.all(compact ? 8 : 24),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF202777),
                    padding: EdgeInsets.symmetric(
                      vertical: compact ? 12 : 18,
                      horizontal: 12,
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
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 24 : 34,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 22 : 36),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: _pickPhoto,
                            customBorder: const CircleBorder(),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: compact ? 54 : 68,
                                  backgroundColor: const Color(0xFF202777),
                                  backgroundImage: _photoBytes == null
                                      ? null
                                      : MemoryImage(_photoBytes!),
                                  child: _photoBytes == null
                                      ? Text(
                                          initial,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: compact ? 44 : 56,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFF2FAE4F),
                                    child: _isPickingPhoto
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: _isPickingPhoto ? null : _pickPhoto,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              _photoBytes == null
                                  ? 'Add profile photo'
                                  : 'Change profile photo',
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ProfileDetail(
                            label: 'Full name',
                            value: widget.ownerName,
                          ),
                          _ProfileDetail(
                            label: 'Business name',
                            value: widget.businessName,
                          ),
                          _ProfileDetail(
                            label: 'Phone number',
                            value: widget.ownerPhone.isEmpty
                                ? 'Not provided'
                                : widget.ownerPhone,
                          ),
                          const SizedBox(height: 18),
                          Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: const Icon(
                                Icons.help_outline,
                                color: Color(0xFF202777),
                              ),
                              title: const Text('Help & Feedback'),
                              subtitle: const Text('FAQs and send feedback'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const HelpFeedbackPage(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text('Log out'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFB3261E),
                                side: const BorderSide(
                                  color: Color(0xFFB3261E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        if (mounted) setState(() => _photoBytes = bytes);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the photo picker.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDDDDD))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF727272))),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
