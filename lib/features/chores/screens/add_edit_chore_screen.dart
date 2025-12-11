import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/houses_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chore.dart';
import '../providers/chores_provider.dart';
// import 'package:intl/intl.dart';

class AddEditChoreScreen extends ConsumerStatefulWidget {
  final Chore? chore;

  const AddEditChoreScreen({super.key, this.chore});

  @override
  ConsumerState<AddEditChoreScreen> createState() => _AddEditChoreScreenState();
}

class _AddEditChoreScreenState extends ConsumerState<AddEditChoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  RepeatSchedule _repeatSchedule = RepeatSchedule.none;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chore?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.chore?.description ?? '',
    );
    _selectedDate = widget.chore?.dueDate;
    _repeatSchedule = widget.chore?.repeatSchedule ?? RepeatSchedule.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChore() async {
    if (!_formKey.currentState!.validate()) return;

    final houseId = ref.read(currentHouseIdProvider);
    if (houseId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No house selected')),
        );
      }
      return;
    }

    // Validation: One-time chores must have a due date
    if (_repeatSchedule == RepeatSchedule.none && _selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a due date or repeat schedule'),
          ),
        );
      }
      return;
    }

    // Default to Today for repeating chores if no date selected
    DateTime? finalDueDate = _selectedDate;
    if (_repeatSchedule != RepeatSchedule.none && finalDueDate == null) {
      finalDueDate = DateTime.now();
    }

    final newChore = Chore(
      id: widget.chore?.id ?? '', // ID is ignored on add, used on update
      houseId: houseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: finalDueDate,
      repeatSchedule: _repeatSchedule,
      assignedToIds:
          widget.chore?.assignedToIds ?? [], // Keep existing assignees for now
      isCompleted: widget.chore?.isCompleted ?? false,
    );

    try {
      if (widget.chore == null) {
        await ref.read(choreControllerProvider.notifier).addChore(newChore);
      } else {
        await ref.read(choreControllerProvider.notifier).updateChore(newChore);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving chore: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chore == null ? 'Add Chore' : 'Edit Chore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textInk),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What needs to be done?',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textInk),
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add details...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primarySea,
                            onPrimary: Colors.white,
                            surface: AppColors.surfaceWood,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundParchment,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textParchment,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select Due Date (Optional)'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? AppColors.textParchment
                              : AppColors.textInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Repeat Schedule Dropdown
              DropdownButtonFormField<RepeatSchedule>(
                value: _repeatSchedule,
                dropdownColor: AppColors.surfaceWood,
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  prefixIcon: Icon(
                    Icons.repeat,
                    color: AppColors.textParchment,
                  ),
                ),
                items: RepeatSchedule.values.map((schedule) {
                  return DropdownMenuItem(
                    value: schedule,
                    child: Text(
                      schedule.name.toUpperCase(),
                      style: const TextStyle(color: AppColors.textInk),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _repeatSchedule = value);
                },
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChore,
                child: Text(
                  widget.chore == null ? 'Create Chore' : 'Save Changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
