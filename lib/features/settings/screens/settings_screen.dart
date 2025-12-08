import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/providers/auth_provider.dart';
import 'package:flutter_app/core/providers/houses_provider.dart';
import 'package:flutter_app/features/settings/widgets/houses_card.dart';
import 'package:flutter_app/features/settings/widgets/profile_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final housesAsyncValue = ref.watch(housesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }
          return ListView(
            children: [
              ProfileCard(
                user: user,
                onSignOut: () {
                  ref.read(authRepositoryProvider).signOut();
                },
              ),
              housesAsyncValue.when(
                data: (houses) => HousesCard(userId: user.uid, houses: houses),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
