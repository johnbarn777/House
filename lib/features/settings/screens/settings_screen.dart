import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/houses_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/houses_card.dart';
import '../widgets/profile_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final housesAsyncValue = ref.watch(housesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundParchment,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundParchment,
                    const Color(0xFFC0B090),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, color: AppColors.textInk),
                      const SizedBox(width: 8),
                      Text(
                        'QUARTERMASTER',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 24,
                          letterSpacing: 2.0,
                          color: AppColors.textInk,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: authState.when(
                    data: (user) {
                      if (user == null) {
                        return const Center(child: Text('Not signed in'));
                      }
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        children: [
                          ProfileCard(
                            user: user,
                            onSignOut: () {
                              ref.read(authRepositoryProvider).signOut();
                            },
                          ),
                          housesAsyncValue.when(
                            data: (houses) =>
                                HousesCard(userId: user.uid, houses: houses),
                            loading: () => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.textInk,
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Text(
                                'Error: $error',
                                style: AppTextStyles.error,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textInk,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: $error', style: AppTextStyles.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
