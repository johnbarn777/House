import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/parchment_card.dart';

class ProfileCard extends StatefulWidget {
  final User user;
  final VoidCallback onSignOut;

  const ProfileCard({super.key, required this.user, required this.onSignOut});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _scheduleController = TextEditingController();

  String? _photoURL;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _scheduleController.text = data['scheduleDescription'] ?? '';
        setState(() {
          _photoURL = data['photoURL'];
        });
      } else {
        _nameController.text = widget.user.displayName ?? '';
        setState(() {
          _photoURL = widget.user.photoURL;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'photoURL': _photoURL,
            'email': widget.user.email,
            'scheduleDescription': _scheduleController.text.trim(),
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Crew manifest updated')));
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${widget.user.uid}.jpg');

        await ref.putFile(File(pickedFile.path));
        final url = await ref.getDownloadURL();

        setState(() {
          _photoURL = url;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .update({'photoURL': url});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParchmentCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: AppColors.textInk),
              const SizedBox(width: 8),
              Text('WANTED', style: AppTextStyles.title),
              const SizedBox(width: 8),
              const Icon(Icons.stars, color: AppColors.textInk),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isEditing ? _pickAndUploadImage : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textInk, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _photoURL != null
                    ? NetworkImage(_photoURL!)
                    : null,
                backgroundColor: AppColors.backgroundParchment,
                child: _photoURL == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.textInk,
                      )
                    : null,
              ),
            ),
          ),
          if (_isEditing)
            TextButton(
              onPressed: _pickAndUploadImage,
              child: Text(
                'Update Portrait',
                style: AppTextStyles.body.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildTextField(_nameController, 'Pirate Name / Alias', Icons.badge),
          const SizedBox(height: 16),
          _buildTextField(
            _phoneController,
            'Signal Code (Phone)',
            Icons.phone,
            type: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            _scheduleController,
            'Watch Schedule',
            Icons.access_time,
            type: TextInputType.multiline,
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const CircularProgressIndicator(color: AppColors.textInk)
          else
            Column(
              children: [
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textLight,
                    ),
                    child: const Text('SEAL MANIFEST'),
                  )
                else
                  OutlinedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textInk,
                      side: const BorderSide(color: AppColors.textInk),
                    ),
                    child: const Text('AMEND RECORD'),
                  ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: widget.onSignOut,
                  child: Text(
                    'ABANDON SHIP (LOGOUT)',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(color: AppColors.textInk),
                const SizedBox(height: 24),

                Text(
                  'CAPTAIN\'S SEAL',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textInk,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feature locked by Quartermaster'),
                          ),
                        );
                      }, // Disabled for simplicity in refactor
                      child: Text(
                        'Change Email',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textParchment)
                            .copyWith(color: AppColors.textParchment),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feature locked by Quartermaster'),
                          ),
                        );
                      },
                      child: Text(
                        'Change Password',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textParchment)
                            .copyWith(color: AppColors.textParchment),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? type,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: type,
      maxLines: maxLines,
      style: AppTextStyles.body.copyWith(color: AppColors.textInk),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textInk),
        labelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textParchment,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textInk),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primarySea, width: 2),
        ),
      ),
    );
  }
}
