import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/houses_provider.dart';
import '../../../core/providers/chores_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_app/features/houses/widgets/join_house_dialog.dart';
import 'package:intl/intl.dart';

class HouseScreen extends ConsumerWidget {
  const HouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(housesProvider);
    final currentHouseId = ref.watch(currentHouseIdProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('House', style: AppTextStyles.cardTitle),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      body: housesAsync.when(
        data: (houses) {
          if (houses.isEmpty) {
            return Center(
              child: Text(
                'No houses found. Create or join a house to get started.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            );
          }

          // Auto-select first house if none selected
          if (currentHouseId == null && houses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(currentHouseIdProvider.notifier)
                  .setHouseId(houses.first.id);
            });
          }

          final currentHouse = houses.firstWhere(
            (h) => h.id == currentHouseId,
            orElse: () => houses.first,
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                // Circular Hero Section
                SizedBox(
                  height: screenWidth,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Large white circle
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: screenWidth * 2,
                          height: screenWidth * 2,
                          decoration: const BoxDecoration(
                            color: AppColors.circleWhite,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // House name and code, positioned in the visible part of circle
                      Positioned(
                        bottom: screenWidth * 0.25,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentHouse.houseName,
                              style: AppTextStyles.houseName,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'House ID: ${currentHouse.id}',
                              style: AppTextStyles.houseCode,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content below the circle
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // House Selector (if multiple houses)
                      if (houses.length > 1) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: currentHouseId ?? houses.first.id,
                            isExpanded: true,
                            dropdownColor: AppColors.cardDark,
                            underline: const SizedBox(),
                            style: AppTextStyles.body,
                            items: houses.map((house) {
                              return DropdownMenuItem(
                                value: house.id,
                                child: Text(house.houseName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(currentHouseIdProvider.notifier)
                                    .setHouseId(value);
                              }
                            },
                          ),
                        ),
                      ],

                      // Upcoming Chores Module
                      _buildUpcomingChoresModule(ref, currentHouse.id),
                      const SizedBox(height: 16),

                      // Members Module
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDarkAlt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Members', style: AppTextStyles.moduleTitle),
                            const SizedBox(height: 8),
                            Text(
                              '${currentHouse.members.length} member(s)',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error: $error', style: AppTextStyles.error)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const JoinHouseDialog(),
          );
        },
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildUpcomingChoresModule(WidgetRef ref, String houseId) {
    final choresAsync = ref.watch(choresProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return choresAsync.when(
      data: (allChores) {
        // Filter chores for current house and sort by due date
        final houseChores =
            allChores.where((chore) => chore.houseId == houseId).toList()
              ..sort((a, b) => a.nextDueAt.compareTo(b.nextDueAt));

        // Separate user's chores from others
        final myUpcomingChores = houseChores
            .where((c) => c.assignedTo == currentUser?.uid)
            .take(3)
            .toList();
        final otherUpcomingChores = houseChores
            .where((c) => c.assignedTo != currentUser?.uid)
            .take(3)
            .toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDarkAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upcoming Chores', style: AppTextStyles.moduleTitle),
              const SizedBox(height: 12),
              if (houseChores.isEmpty)
                Text(
                  'No chores scheduled yet.',
                  style: AppTextStyles.bodySecondary,
                )
              else ...[
                // My upcoming chores
                if (myUpcomingChores.isNotEmpty) ...[
                  Text(
                    'Your Chores:',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...myUpcomingChores.map(
                    (chore) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(chore.title, style: AppTextStyles.body),
                          ),
                          Text(
                            DateFormat('MMM d').format(chore.nextDueAt),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (otherUpcomingChores.isNotEmpty)
                    const SizedBox(height: 12),
                ],
                // Other upcoming chores
                if (otherUpcomingChores.isNotEmpty) ...[
                  if (myUpcomingChores.isNotEmpty)
                    Text(
                      'Other Chores:',
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ...otherUpcomingChores.map(
                    (chore) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              chore.title,
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(chore.nextDueAt),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDarkAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Chores', style: AppTextStyles.moduleTitle),
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDarkAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Chores', style: AppTextStyles.moduleTitle),
            const SizedBox(height: 8),
            Text('Failed to load chores', style: AppTextStyles.error),
          ],
        ),
      ),
    );
  }
}
