import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';
import '../services/gamification_service.dart';
import '../../../core/providers/user_provider.dart';

class QuartermasterStoreDialog extends ConsumerStatefulWidget {
  const QuartermasterStoreDialog({super.key});

  @override
  ConsumerState<QuartermasterStoreDialog> createState() =>
      _QuartermasterStoreDialogState();
}

class _QuartermasterStoreDialogState
    extends ConsumerState<QuartermasterStoreDialog> {
  // Hardcoded for now, could be fetched from Firestore 'store_items' collection
  final List<Map<String, dynamic>> _storeItems = [
    {
      'id': 'snooze_token',
      'name': 'Snooze Token',
      'emoji': '💤',
      'cost': 50,
      'description': 'Extend a deadline by 24h without penalty.',
    },
    {
      'id': 'veto_card',
      'name': 'Veto Card',
      'emoji': '📜',
      'cost': 150,
      'description': 'Re-roll a chore assignment.',
    },
    {
      'id': 'skip_pass',
      'name': 'Shore Leave',
      'emoji': '🏝️',
      'cost': 500,
      'description': 'Skip one turn of a rotating chore.',
    },
  ];

  Future<void> _purchaseItem(
    UserProfile user,
    String itemId,
    int cost,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Buy $name?'),
        content: Text('This will cost $cost Doubloons.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Optimistic upate or wait? Service waits.
      // Show loading?
      try {
        final success = await ref
            .read(gamificationServiceProvider)
            .purchaseItem(userId: user.id, itemId: itemId, cost: cost);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Purchased $name!')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase failed (Insufficient funds?)'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 500,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quartermaster Store',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Carter One',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            userAsync.when(
              data: (user) {
                if (user == null)
                  return const Center(child: Text("Please login"));
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Your Balance: "),
                          Text(
                            "${user.doubloons} 💰",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 350, // Fixed height for list
                      child: ListView.separated(
                        itemCount: _storeItems.length,
                        separatorBuilder: (ctx, i) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final item = _storeItems[i];
                          final canAfford =
                              user.doubloons >= (item['cost'] as int);

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['emoji'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            title: Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              (item['description'] as String) +
                                  "\nCost: ${item['cost']} 💰",
                            ),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                              onPressed: canAfford
                                  ? () => _purchaseItem(
                                      user,
                                      item['id'] as String,
                                      item['cost'] as int,
                                      item['name'] as String,
                                    )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford
                                    ? Colors.amber
                                    : Colors.grey,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text("Buy"),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text("Error: $e")),
            ),
          ],
        ),
      ),
    );
  }
}
