// App.tsx
import React, { useEffect } from 'react';
import {
  View,
  ActivityIndicator,
  Text,
  StyleSheet,
  Platform
} from 'react-native';
import {
  NavigationContainer,
  createNavigationContainerRef
} from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import messaging from '@react-native-firebase/messaging';
import notifee, {
  AndroidImportance,
  EventType,
  TimestampTrigger,
  TriggerType
} from '@notifee/react-native';

import AuthenticationScreen from './screens/AuthenticationScreen';
import MainNavigator       from './screens/MainNavigator';

import { useAuth }           from './src/hooks/useAuth';
import {
  HousesProvider,
  useHouses
} from './src/contexts/HousesContext';
import { UsersProvider }     from './src/contexts/UsersContext';

const Stack = createStackNavigator();
export const navigationRef = createNavigationContainerRef();

// Create default notification channel on Android
async function createNotificationChannel() {
  if (Platform.OS === 'android') {
    await notifee.createChannel({
      id: 'default',
      name: 'Default Notifications',
      importance: AndroidImportance.DEFAULT
    });
  }
}

// Display an incoming FCM message via Notifee
async function displayNotification(remoteMessage: any) {
  await notifee.displayNotification({
    title: remoteMessage.notification?.title,
    body: remoteMessage.notification?.body,
    android: {
      channelId: 'default',
      pressAction: { id: 'default' }
    },
    data: remoteMessage.data
  });
}

// DEV helper: schedule a local test notification 5s from now
async function testLocalReminder() {
  const timestamp = Date.now() + 5000;
  await notifee.createTriggerNotification(
    {
      id: 'test-reminder',
      title: '🚀 Test Notification',
      body: 'This was scheduled 5 seconds ago',
      android: { channelId: 'default' }
    },
    {
      type: TriggerType.TIMESTAMP,
      timestamp
    } as TimestampTrigger
  );
}

// Background handler (app killed / background)
messaging().setBackgroundMessageHandler(async remoteMessage => {
  await createNotificationChannel();
  await displayNotification(remoteMessage);
});

function AppContent() {
  const { user, initializing } = useAuth();
  const { currentHouseId }     = useHouses();

  useEffect(() => {
    // 1) Ensure channel exists
    createNotificationChannel();

    // 2) DEV-only test
    if (__DEV__) testLocalReminder();

    // 3) Foreground FCM messages
    const unsubMsg = messaging().onMessage(async remoteMessage => {
      await displayNotification(remoteMessage);
    });

    // 4) If the app was quit and opened via tapping a notification
    messaging()
      .getInitialNotification()
      .then(remoteMessage => {
        const choreId = remoteMessage?.data?.choreId;
        if (choreId) {
          navigationRef.current?.navigate('Main', {
            screen: 'Chores',
            params: { openComplete: choreId }
          });
        }
      });

    // 5) If the app was backgrounded and then notification is tapped
    const unsubOpen = messaging().onNotificationOpenedApp(remoteMessage => {
      const choreId = remoteMessage.data?.choreId;
      if (choreId) {
        navigationRef.current?.navigate('Main', {
          screen: 'Chores',
          params: { openComplete: choreId }
        });
      }
    });

    // 6) Notifee foreground‐press events (for real device taps)
    const unsubNotifee = notifee.onForegroundEvent(({ type, detail }) => {
      if (type === EventType.PRESS) {
        const choreId = detail.notification.data.choreId;
        navigationRef.current?.navigate('Main', {
          screen: 'Chores',
          params: { openComplete: choreId }
        });
      }
    });

    return () => {
      unsubMsg();
      unsubOpen();
      unsubNotifee();
    };
  }, []);

  if (initializing) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
        <Text>Loading…</Text>
      </View>
    );
  }

  return (
    <NavigationContainer ref={navigationRef}>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          <Stack.Screen name="Main">
            {() =>
              currentHouseId ? (
                <UsersProvider houseId={currentHouseId}>
                  <MainNavigator />
                </UsersProvider>
              ) : (
                <View style={styles.center}>
                  <Text>No house selected</Text>
                </View>
              )
            }
          </Stack.Screen>
        ) : (
          <Stack.Screen
            name="Auth"
            component={AuthenticationScreen}
          />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default function App() {
  return (
    <HousesProvider>
      <AppContent />
    </HousesProvider>
  );
}

const styles = StyleSheet.create({
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center'
  }
});
