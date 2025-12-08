import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/models/house.dart';
import 'package:flutter_app/core/providers/houses_provider.dart';

class HousesCard extends ConsumerWidget {
  final String userId;
  final List<House> houses;

  const HousesCard({super.key, required this.userId, required this.houses});

  Future<void> _leaveHouse(
    BuildContext context,
    String houseId,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave house?'),
        content: const Text('Are you sure you want to leave this house?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('houses')
            .doc(houseId)
            .update({
              'members': FieldValue.arrayRemove([userId]),
            });

        // If current house is the one left, clear selection
        final currentHouseId = ref.read(currentHouseIdProvider);
        if (currentHouseId == houseId) {
          ref.read(currentHouseIdProvider.notifier).setHouseId(null);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error leaving house: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHouseId = ref.watch(currentHouseIdProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Houses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (houses.isEmpty)
              const Text(
                'You aren’t in any houses.',
                textAlign: TextAlign.center,
              )
            else
              ...houses.map((house) {
                final isActive = house.id == currentHouseId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: isActive
                      ? BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  child: ListTile(
                    title: Text(
                      house.houseName,
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                          ),
                          onPressed: () => _leaveHouse(context, house.id, ref),
                        ),
                      ],
                    ),
                    onTap: () {
                      ref
                          .read(currentHouseIdProvider.notifier)
                          .setHouseId(house.id);
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
