import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/house.dart';
import '../../../core/providers/houses_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/plank_container.dart';

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
        backgroundColor: AppColors.backgroundParchment,
        title: Text(
          'MUTINY?',
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.textInk),
        ),
        content: Text('Sever ties with this crew?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('STAY', style: AppTextStyles.button),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'JUMP SHIP',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
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

        final currentHouseId = ref.read(currentHouseIdProvider);
        if (currentHouseId == houseId) {
          ref.read(currentHouseIdProvider.notifier).setHouseId(null);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error leaving ship: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHouseId = ref.watch(currentHouseIdProvider);

    return PlankContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'FLEET REGISTRY',
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (houses.isEmpty)
            Text(
              'No ships in fleet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLight.copyWith(
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...houses.map((house) {
              final isActive = house.id == currentHouseId;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondaryGold.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? AppColors.secondaryGold
                        : AppColors.textLight.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  title: Text(
                    house.houseName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? AppColors.secondaryGold
                          : AppColors.textLight,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        const Icon(
                          Icons.anchor,
                          color: AppColors.secondaryGold,
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: AppColors.error,
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
    );
  }
}
