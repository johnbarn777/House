import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_app/features/chores/models/chore.dart';
import '../utils/notification_quips.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _onNotificationTapController =
      StreamController<String>.broadcast();

  Stream<String> get onNotificationTap => _onNotificationTapController.stream;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final dynamic localTimezone = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = localTimezone is String
          ? localTimezone
          : localTimezone.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Could not set local location, defaulting to UTC: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _onNotificationTapController.add(details.payload!);
        }
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleChoreNotifications(Chore chore) async {
    if (chore.dueDate == null || chore.isCompleted) return;

    await cancelChoreNotifications(chore);

    final dueDate = chore.dueDate!;

    // 1. Day Before (6 PM)
    await _scheduleStage(
      chore,
      NotificationStage.dayBefore,
      _setHour(dueDate.subtract(const Duration(days: 1)), 18),
    );

    // 2. Morning (9 AM)
    await _scheduleStage(
      chore,
      NotificationStage.morning,
      _setHour(dueDate, 9),
    );

    // 3. Noon (12 PM)
    await _scheduleStage(chore, NotificationStage.noon, _setHour(dueDate, 12));

    // 4. Evening (7 PM)
    await _scheduleStage(
      chore,
      NotificationStage.evening,
      _setHour(dueDate, 19),
    );

    // 5. Day After (9 AM)
    await _scheduleStage(
      chore,
      NotificationStage.dayAfter,
      _setHour(dueDate.add(const Duration(days: 1)), 9),
    );
  }

  Future<void> _scheduleStage(
    Chore chore,
    NotificationStage stage,
    DateTime scheduledDate,
  ) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final id = _generateId(chore.id, stage);
    final title = "Chore: ${chore.title}";
    final body = NotificationQuips.getQuip(stage, chore.title);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chores_channel',
          'Chores',
          channelDescription: 'Reminders for chores',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelChoreNotifications(Chore chore) async {
    for (final stage in NotificationStage.values) {
      await _notificationsPlugin.cancel(_generateId(chore.id, stage));
    }
  }

  int _generateId(String choreId, NotificationStage stage) {
    // Combine hashcodes to create a unique integer ID
    // Using a prime multiplier to reduce collisions
    // And ensure positive integer
    return (choreId.hashCode ^ (stage.index * 31)).abs();
  }

  DateTime _setHour(DateTime date, int hour) {
    return DateTime(date.year, date.month, date.day, hour, 0, 0);
  }
}
