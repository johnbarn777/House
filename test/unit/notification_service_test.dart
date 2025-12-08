import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_app/core/services/notification_service.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([
  FirebaseMessaging,
  FlutterLocalNotificationsPlugin,
  NotificationSettings,
])
void main() {
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
  late NotificationService notificationService;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService(
      firebaseMessaging: mockFirebaseMessaging,
      localNotifications: mockLocalNotifications,
    );
  });

  group('NotificationService', () {
    test(
      'initialize requests permissions and initializes local notifications',
      () async {
        // Arrange
        final mockSettings = MockNotificationSettings();
        when(
          mockFirebaseMessaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => mockSettings);

        when(
          mockLocalNotifications.initialize(
            any,
            onDidReceiveNotificationResponse: anyNamed(
              'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await notificationService.initialize();

        // Assert
        verify(
          mockFirebaseMessaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).called(1);

        verify(
          mockLocalNotifications.initialize(
            any,
            onDidReceiveNotificationResponse: anyNamed(
              'onDidReceiveNotificationResponse',
            ),
          ),
        ).called(1);
      },
    );

    test('getToken returns token from FirebaseMessaging', () async {
      // Arrange
      const token = 'test_token';
      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => token);

      // Act
      final result = await notificationService.getToken();

      // Assert
      expect(result, token);
      verify(mockFirebaseMessaging.getToken()).called(1);
    });
  });
}
