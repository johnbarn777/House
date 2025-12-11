import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/houses_provider.dart';
import '../../chores/providers/chores_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/plank_container.dart';
import '../widgets/join_house_dialog.dart';
import '../../house_notes/widgets/house_notes_module.dart';
import '../../gamification/services/ship_health_service.dart';
import '../../gamification/widgets/doubloon_counter.dart';
import '../../gamification/widgets/quartermaster_store_dialog.dart';
import '../../gamification/widgets/leaderboard_card.dart';

class HouseScreen extends ConsumerWidget {
  const HouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(housesProvider);
    final currentHouseId = ref.watch(currentHouseIdProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment, // Parchment background
      body: Stack(
        children: [
          // Background Texture (Gradient for now)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundParchment,
                    AppColors.backgroundParchment.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          housesAsync.when(
            data: (houses) {
              if (houses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('NO SHIP DOCKED', style: AppTextStyles.title),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primarySea,
                          foregroundColor: AppColors.secondaryGold,
                          textStyle: AppTextStyles.button,
                        ),
                        child: const Text("SIGN SHIP'S CHARTER"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const JoinHouseDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              // Auto-select first house logic
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

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "CAPTAIN'S LOG",
                              style: AppTextStyles.moduleTitle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const DoubloonCounter(),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.store,
                                color: AppColors.textInk,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      const QuartermasterStoreDialog(),
                                );
                              },
                            ),
                            // House Selector (Mini)
                            if (houses.length > 1)
                              DropdownButton<String>(
                                value: currentHouseId ?? houses.first.id,
                                items: houses
                                    .map(
                                      (house) => DropdownMenuItem(
                                        value: house.id,
                                        child: Text(
                                          house.houseName,
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.textInk,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    ref
                                        .read(currentHouseIdProvider.notifier)
                                        .setHouseId(v);
                                  }
                                },
                                dropdownColor: AppColors.backgroundParchment,
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.textInk,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Ship Status (Replaces Reactor Core)
                      // Temporary placeholder for Ship Wheel
                      // Ship Status Wheel
                      Consumer(
                        builder: (context, ref, _) {
                          final health = ref.watch(shipHealthProvider);
                          final status = ref.watch(shipStatusProvider);

                          Color statusColor;
                          if (health >= 70) {
                            statusColor = AppColors.success;
                          } else if (health >= 30) {
                            statusColor = AppColors.warning;
                          } else {
                            statusColor = AppColors.error;
                          }

                          return Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceWood,
                              border: Border.all(color: statusColor, width: 6),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                const BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    health > 0
                                        ? Icons.anchor
                                        : Icons.warning_amber_rounded,
                                    size: 48,
                                    color: statusColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${health.toInt()}%',
                                    style: AppTextStyles.title.copyWith(
                                      color: statusColor,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Modules Container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Upcoming Chores (The Job Board)
                            _buildUpcomingChoresModule(ref, currentHouse.id),
                            const SizedBox(height: 16),

                            // House Notes Module (The Scroll)
                            // This widget needs its own internal refactor, but for now it sits here.
                            const HouseNotesModule(), // Needs its own refactor to match style but for now it's placed here

                            const SizedBox(height: 16),

                            // Leaderboard
                            const LeaderboardCard(),

                            const SizedBox(height: 16),

                            // Members (The Crew)
                            PlankContainer(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        color: AppColors.secondaryGold,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'THE CREW',
                                        style: AppTextStyles.cardTitle.copyWith(
                                          color: AppColors.secondaryGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: currentHouse.members
                                        .map(
                                          (m) => Chip(
                                            label: Text(
                                              m,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color: AppColors.textInk,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            backgroundColor:
                                                AppColors.backgroundParchment,
                                            side: const BorderSide(
                                              color: AppColors.textInk,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textInk),
            ),
            error: (error, stack) => Center(
              child: Text(
                'SHIPWRECK ERROR: $error',
                style: AppTextStyles.error,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const JoinHouseDialog(),
            );
          },
          backgroundColor: AppColors.accentRed, // Red wax seal color
          child: const Icon(Icons.add, color: AppColors.textLight),
        ),
      ),
    );
  }

  Widget _buildUpcomingChoresModule(WidgetRef ref, String houseId) {
    final choresAsync = ref.watch(choresProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return choresAsync.when(
      data: (allChores) {
        final houseChores = allChores.toList()
          ..sort(
            (a, b) => (a.dueDate ?? DateTime.now()).compareTo(
              b.dueDate ?? DateTime.now(),
            ),
          );

        // Separate user's chores from others
        final myUpcomingChores = houseChores
            .where(
              (c) =>
                  c.assignedToIds.contains(currentUser?.uid) && !c.isCompleted,
            )
            .take(3)
            .toList();
        final otherUpcomingChores = houseChores
            .where(
              (c) =>
                  !c.assignedToIds.contains(currentUser?.uid) && !c.isCompleted,
            )
            .take(3)
            .toList();

        return PlankContainer(
          // Wood background for job board
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DUTY ROSTER', style: AppTextStyles.cardTitle),
                  if (myUpcomingChores.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: Text(
                        "ALL HANDS!",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Internal parchment area for list
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundParchment,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (houseChores.where((c) => !c.isCompleted).isEmpty)
                      Text(
                        'Decks are clean, Captain.',
                        style: AppTextStyles.body.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else ...[
                      if (myUpcomingChores.isNotEmpty) ...[
                        Text(
                          'YOUR ORDERS:',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 14,
                            color: AppColors.textInk,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...myUpcomingChores.map(
                          (chore) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .check_box_outline_blank, // Old style checkbox
                                  size: 20,
                                  color: AppColors.textInk,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    chore.title,
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                if (chore.dueDate != null)
                                  Text(
                                    DateFormat('MMM d').format(chore.dueDate!),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (otherUpcomingChores.isNotEmpty)
                          const Divider(color: AppColors.textInk),
                      ],

                      if (otherUpcomingChores.isNotEmpty) ...[
                        if (myUpcomingChores.isNotEmpty)
                          Text(
                            'CREW ASSIGNMENTS:',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 8),
                        ...otherUpcomingChores.map(
                          (chore) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.textParchment,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    chore.title,
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const PlankContainer(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondaryGold),
        ),
      ),
      error: (error, stack) => PlankContainer(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to read logs', style: AppTextStyles.error),
      ),
    );
  }
}
