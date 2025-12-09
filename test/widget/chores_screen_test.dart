import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/core/models/chore.dart';
import 'package:flutter_app/core/providers/auth_provider.dart';
import 'package:flutter_app/core/providers/chores_provider.dart';
import 'package:flutter_app/core/providers/houses_provider.dart';
import 'package:flutter_app/core/services/chores_repository.dart';
import 'package:flutter_app/features/chores/screens/chores_screen.dart';

import 'chores_screen_test.mocks.dart';

@GenerateMocks([ChoresRepository, User])
void main() {
  late MockChoresRepository mockChoresRepository;
  late MockUser mockUser;

  setUp(() {
    mockChoresRepository = MockChoresRepository();
    mockUser = MockUser();
    when(mockUser.uid).thenReturn('test_user_id');
  });

  testWidgets('ChoresScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          choresProvider.overrideWith((ref) => Stream.value([])),
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          currentHouseIdProvider.overrideWith(
            () => MockCurrentHouseIdNotifier(),
          ),
        ],
        child: const MaterialApp(home: ChoresScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('No chores found. Add one to get started!'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('ChoresScreen shows chores list', (tester) async {
    final chore1 = Chore(
      id: '1',
      title: 'Clean Kitchen',
      assignedTo: 'test_user_id',
      nextDueAt: DateTime.now(),
      schedule: Schedule(frequency: 'Daily', interval: 1),
      houseId: 'test_house_id',
    );

    final chore2 = Chore(
      id: '2',
      title: 'Mow Lawn',
      assignedTo: 'other_user_id',
      nextDueAt: DateTime.now(),
      schedule: Schedule(frequency: 'Weekly', interval: 1),
      houseId: 'test_house_id',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          choresProvider.overrideWith((ref) => Stream.value([chore1, chore2])),
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          currentHouseIdProvider.overrideWith(
            () => MockCurrentHouseIdNotifier(),
          ),
          choresRepositoryProvider.overrideWithValue(mockChoresRepository),
        ],
        child: const MaterialApp(home: ChoresScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Chores'), findsOneWidget);
    expect(find.text('Clean Kitchen'), findsOneWidget);
    expect(find.text('Other Chores'), findsOneWidget);
    expect(find.text('Mow Lawn'), findsOneWidget);
  });

  testWidgets('ChoresScreen FAB opens AddEditChoreScreen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          choresProvider.overrideWith((ref) => Stream.value([])),
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          currentHouseIdProvider.overrideWith(
            () => MockCurrentHouseIdNotifier(),
          ),
        ],
        child: const MaterialApp(home: ChoresScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify we navigated to AddEditChoreScreen
    // Since we can't easily check the route stack without a mock navigator,
    // we check for a widget that is unique to AddEditChoreScreen, e.g., 'Add Chore' title
    expect(find.text('Add Chore'), findsOneWidget);
  });
}

class MockCurrentHouseIdNotifier extends CurrentHouseIdNotifier {
  @override
  String? build() => 'test_house_id';
}
