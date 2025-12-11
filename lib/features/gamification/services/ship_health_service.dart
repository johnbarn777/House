import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chores/providers/chores_provider.dart';

final shipHealthProvider = Provider<double>((ref) {
  final choresAsync = ref.watch(choresProvider);

  return choresAsync.when(
    data: (chores) {
      double health = 100.0;

      // Calculate Decay
      int overdueCount = 0;
      for (final chore in chores) {
        if (!chore.isCompleted && chore.dueDate != null) {
          // Check if overdue by more than 24 hours
          final deadline = chore.dueDate!.add(const Duration(hours: 24));
          if (DateTime.now().isAfter(deadline)) {
            overdueCount++;
          }
        }
      }

      double penalty = overdueCount * 5.0; // -5% per overdue chore
      health -= penalty;

      // Calculate Repair (Bonus for recently completed chores)
      // For MVP, we'll just add bonus for visible completed chores in the list
      int completedCount = chores.where((c) => c.isCompleted).length;
      double bonus = completedCount * 2.0; // +2% per completed chore

      health += bonus;

      // Clamp between 0 and 100
      if (health > 100.0) health = 100.0;
      if (health < 0.0) health = 0.0;

      return health;
    },
    loading: () => 100.0,
    error: (_, __) => 0.0,
  );
});

final shipStatusProvider = Provider<String>((ref) {
  final health = ref.watch(shipHealthProvider);

  if (health >= 90) return 'SMOOTH SAILING';
  if (health >= 70) return 'CHOPPY WATERS';
  if (health >= 50) return 'STORM AHEAD';
  if (health >= 30) return 'TAKING ON WATER';
  return 'ABANDON SHIP!';
});
