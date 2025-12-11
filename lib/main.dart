import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/houses/screens/house_screen.dart';
import 'features/chores/screens/chores_screen.dart';
import 'features/fridge/screens/fridge_screen.dart';
import 'features/fridge/screens/add_edit_fridge_item_screen.dart';
import 'features/fridge/models/fridge_item.dart';
import 'features/settings/screens/settings_screen.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

import 'core/widgets/command_dock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const ProviderScope(child: MyApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/house',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/house',
            builder: (context, state) => const HouseScreen(),
          ),
          GoRoute(
            path: '/chores',
            builder: (context, state) => const ChoresScreen(),
          ),
          GoRoute(
            path: '/chores',
            builder: (context, state) => const ChoresScreen(),
          ),
          GoRoute(
            path: '/fridge',
            builder: (context, state) => const FridgeScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/fridge/add',
        builder: (context, state) => const AddEditFridgeItemScreen(),
      ),
      GoRoute(
        path: '/fridge/edit',
        builder: (context, state) =>
            AddEditFridgeItemScreen(item: state.extra as FridgeItem),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/house';

      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges,
    ),
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();

    notificationService.onNotificationTap.listen((choreId) {
      debugPrint('Notification tapped for chore: $choreId');
      // TODO: Implement actual navigation
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'House App',
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Extend body behind the dock
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          child,
          Align(
            alignment: Alignment.bottomCenter,
            child: CommandDock(
              selectedIndex: _calculateSelectedIndex(context),
              onItemSelected: (index) => _onItemTapped(index, context),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/house')) return 0;
    if (location.startsWith('/chores')) return 1;
    if (location.startsWith('/fridge')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/house');
        break;
      case 1:
        context.go('/chores');
        break;
      case 2:
        context.go('/fridge');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
