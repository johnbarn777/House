import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gamification/services/gamification_service.dart';
import '../../../core/providers/user_provider.dart';

class SnoozeChoreDialog extends ConsumerStatefulWidget {
  final DateTime currentDueDate;
  final String? choreId; // Added to enable token usage

  const SnoozeChoreDialog({
    super.key,
    required this.currentDueDate,
    this.choreId,
  });

  @override
  ConsumerState<SnoozeChoreDialog> createState() => _SnoozeChoreDialogState();
}

class _SnoozeChoreDialogState extends ConsumerState<SnoozeChoreDialog> {
  final _reasonController = TextEditingController();
  DateTime? _newDueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _setDate(DateTime date) {
    setState(() {
      _newDueDate = date;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _newDueDate != null) {
      Navigator.of(
        context,
      ).pop({'date': _newDueDate, 'reason': _reasonController.text.trim()});
    } else if (_newDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a new due date')),
      );
    }
  }

  Future<void> _useSnoozeToken(String userId) async {
    if (_newDueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pick a date first!')));
      return;
    }

    try {
      // Consume token
      await ref
          .read(gamificationServiceProvider)
          .consumeItem(userId: userId, itemId: 'snooze_token');

      // Actually, let's fix the service in next step.
      // For now, just return a special reason.
      Navigator.of(
        context,
      ).pop({'date': _newDueDate, 'reason': 'Used Snooze Token 💤'});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildDateOption(
    String label,
    DateTime date, {
    bool isCustom = false,
  }) {
    final isSelected =
        _newDueDate != null &&
        DateUtils.isSameDay(_newDueDate!, date) &&
        !isCustom;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isCustom) {
            showDatePicker(
              context: context,
              initialDate: widget.currentDueDate.add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primarySea,
                      onPrimary: Colors.white,
                      surface: AppColors.backgroundParchment,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            ).then((picked) {
              if (picked != null) {
                _setDate(picked);
              }
            });
          } else {
            _setDate(date);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySea : AppColors.surfaceWood,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.white, width: 1)
                : null,
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.textInk,
                ),
              ),
              if (!isCustom)
                Text(
                  DateFormat('MMM d').format(date),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textParchment,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Dialog(
      backgroundColor: AppColors.backgroundParchment,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Snooze Chore',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              Text(
                'Snooze until...',
                style: GoogleFonts.montserrat(
                  color: AppColors.textParchment,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildDateOption(
                    'Tomorrow',
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                  _buildDateOption(
                    'In 2 Days',
                    DateTime.now().add(const Duration(days: 2)),
                  ),
                  _buildDateOption(
                    'Next Week',
                    DateTime.now().add(const Duration(days: 7)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: widget.currentDueDate.isBefore(DateTime.now())
                        ? DateTime.now().add(const Duration(days: 1))
                        : widget.currentDueDate.add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primarySea,
                            onPrimary: Colors.white,
                            surface: AppColors.backgroundParchment,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    _setDate(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        _newDueDate != null &&
                            !_isPreset(DateTime.now(), _newDueDate!)
                        ? AppColors.primarySea
                        : AppColors.surfaceWood,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        (_newDueDate != null &&
                            !_isPreset(DateTime.now(), _newDueDate!))
                        ? Border.all(color: Colors.white, width: 1)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (_newDueDate != null &&
                            !_isPreset(DateTime.now(), _newDueDate!))
                        ? 'Custom: ${DateFormat('MMM d, y').format(_newDueDate!)}'
                        : 'Select Custom Date...',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          (_newDueDate != null &&
                              !_isPreset(DateTime.now(), _newDueDate!))
                          ? Colors.white
                          : AppColors.textInk,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              userAsync.when(
                data: (user) {
                  final hasToken = (user?.inventory['snooze_token'] ?? 0) > 0;
                  if (!hasToken) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () => _useSnoozeToken(user!.id),
                      icon: const Icon(
                        Icons.confirmation_number,
                      ), // Ticket icon
                      label: const Text("Use Snooze Token (Skip Approval)"),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Success Reason (Required)',
                  labelStyle: const TextStyle(color: AppColors.textParchment),
                  hintText: 'Why are you delaying this?',
                  hintStyle: const TextStyle(color: AppColors.textParchment),
                  filled: true,
                  fillColor: AppColors.surfaceWood,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  // If token used, this might be bypassed, but here we enforce it for manual.
                  // Since token button pops immediately, this validator only runs for manual Submit.
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(
                        color: AppColors.textParchment,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySea,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Snooze Chore'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPreset(DateTime now, DateTime target) {
    return false; // logic handled in tapping
  }
}
