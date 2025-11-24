import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/chore.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/chores_provider.dart';
import '../../../core/providers/houses_provider.dart';
import '../../../core/services/users_repository.dart';

final houseMembersProvider = FutureProvider.autoDispose<List<UserProfile>>((
  ref,
) async {
  final currentHouse = await ref.watch(currentHouseProvider.future);
  if (currentHouse == null) return [];

  return ref.watch(usersRepositoryProvider).getUsers(currentHouse.members);
});

class AddEditChoreScreen extends ConsumerStatefulWidget {
  final Chore? chore;

  const AddEditChoreScreen({super.key, this.chore});

  @override
  ConsumerState<AddEditChoreScreen> createState() => _AddEditChoreScreenState();
}

class _AddEditChoreScreenState extends ConsumerState<AddEditChoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String _frequency = 'Weekly';
  int _interval = 1;
  String? _assignedTo;
  DateTime _nextDueAt = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chore?.title ?? '');
    if (widget.chore != null) {
      _frequency = widget.chore!.schedule.frequency;
      _interval = widget.chore!.schedule.interval;
      _assignedTo = widget.chore!.assignedTo;
      _nextDueAt = widget.chore!.nextDueAt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveChore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final houseId = ref.read(currentHouseIdProvider);
      if (houseId == null) throw Exception('No house selected');

      final schedule = Schedule(frequency: _frequency, interval: _interval);

      final newChore = Chore(
        id: widget.chore?.id ?? '', // ID ignored for add
        title: _titleController.text.trim(),
        assignedTo: _assignedTo,
        nextDueAt: _nextDueAt,
        schedule: schedule,
        houseId: houseId,
      );

      if (widget.chore == null) {
        await ref.read(choresRepositoryProvider).addChore(houseId, newChore);
      } else {
        await ref.read(choresRepositoryProvider).updateChore(houseId, newChore);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(houseMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chore == null ? 'Add Chore' : 'Edit Chore'),
        actions: [
          if (widget.chore != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Chore'),
                    content: const Text(
                      'Are you sure you want to delete this chore?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final houseId = ref.read(currentHouseIdProvider);
                  if (houseId != null) {
                    await ref
                        .read(choresRepositoryProvider)
                        .deleteChore(houseId, widget.chore!.id);
                    if (!context.mounted) return;
                    context.pop();
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a title'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: [
                'Daily',
                'Weekly',
                'Bi-weekly',
                'Monthly',
              ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (value) => setState(() => _frequency = value!),
            ),
            const SizedBox(height: 16),
            membersAsync.when(
              data: (members) => DropdownButtonFormField<String>(
                value: _assignedTo,
                decoration: const InputDecoration(labelText: 'Assign To'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...members.map(
                    (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.displayName ?? m.email),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _assignedTo = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error loading members: $e'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChore,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.chore == null ? 'Add Chore' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
