import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChoreCompletionDialog extends ConsumerStatefulWidget {
  final String choreId;

  const ChoreCompletionDialog({super.key, required this.choreId});

  @override
  ConsumerState<ChoreCompletionDialog> createState() =>
      _ChoreCompletionDialogState();
}

class _ChoreCompletionDialogState extends ConsumerState<ChoreCompletionDialog> {
  final _noteController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isUploading = true;
    });

    try {
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await ref
            .read(storageServiceProvider)
            .uploadFile(_selectedImage!, 'chore_completions/${widget.choreId}');
      }

      if (mounted) {
        Navigator.of(context).pop({
          'note': _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          'photoUrl': photoUrl,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading photo: $e')));
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundParchment,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Complete Chore', style: AppTextStyles.cardTitle),
            const SizedBox(height: 20),

            // Photo Section
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: AppColors.primarySea,
                    ),
                    label: Text('Camera', style: AppTextStyles.body),
                  ),
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.photo_library,
                      color: AppColors.primarySea,
                    ),
                    label: Text('Gallery', style: AppTextStyles.body),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Note Section
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)...',
                hintStyle: AppTextStyles.bodyLight,
                filled: true,
                fillColor: AppColors.surfaceWood,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextStyles.body,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Actions
            if (_isUploading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: AppTextStyles.bodyLight),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySea,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
