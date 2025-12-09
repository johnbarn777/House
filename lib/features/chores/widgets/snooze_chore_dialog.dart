import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class SnoozeChoreDialog extends StatefulWidget {
  final DateTime currentDueDate;

  const SnoozeChoreDialog({super.key, required this.currentDueDate});

  @override
  State<SnoozeChoreDialog> createState() => _SnoozeChoreDialogState();
}

class _SnoozeChoreDialogState extends State<SnoozeChoreDialog> {
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

  Widget _buildDateOption(
    String label,
    DateTime date, {
    bool isCustom = false,
  }) {
    final isSelected =
        _newDueDate != null &&
        DateUtils.isSameDay(_newDueDate!, date) &&
        !isCustom;
    // For custom, checking exact equality might be tricky if time is involved, but usually date picker returns midnight.
    // Simplifying: Just distinct colors.

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
                      primary: AppColors.primaryPurple,
                      onPrimary: Colors.white,
                      surface: AppColors.cardDark,
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
            color: isSelected ? AppColors.primaryPurple : AppColors.inputBg,
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
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (!isCustom)
                Text(
                  DateFormat('MMM d').format(date),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textSecondary,
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
    return Dialog(
      backgroundColor: AppColors.cardDark,
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
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Preset Options Row
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
              // Custom Date using the same style logic for consistency
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
                            primary: AppColors.primaryPurple,
                            onPrimary: Colors.white,
                            surface: AppColors.cardDark,
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
                        ? AppColors.primaryPurple
                        : AppColors.inputBg,
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
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Success Reason (Required)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Why are you delaying this?',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
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
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
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
    // Basic check for UI highlighting logic if needed, simplifed for now based on button taps
    return false; // logic handled in tapping
  }
}
