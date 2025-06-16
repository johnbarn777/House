// App.tsx
import React from 'react';
import { View, ActivityIndicator, Text, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator }  from '@react-navigation/stack';

import AuthenticationScreen from './screens/AuthenticationScreen';
import MainNavigator       from './screens/MainNavigator';

import { useAuth }          from './src/hooks/useAuth';
import { HousesProvider, useHouses } from './src/contexts/HousesContext';
import { UsersProvider }    from './src/contexts/UsersContext';

const Stack = createStackNavigator();

function AppContent() {
  const { user, initializing } = useAuth();
  const { currentHouseId }     = useHouses();

  if (initializing) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
        <Text>Loading…</Text>
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (
          <Stack.Screen name="Main">
            {() =>
              // Only start the UsersProvider once we have a valid house ID
              currentHouseId ? (
                <UsersProvider houseId={currentHouseId}>
                  <MainNavigator />
                </UsersProvider>
              ) : (
                // You could show a “choose your house” screen here
                <View style={styles.center}>
                  <Text>No house selected</Text>
                </View>
              )
            }
          </Stack.Screen>
        ) : (
          <Stack.Screen name="Auth" component={AuthenticationScreen} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default function App() {
  return (
    // HousesProvider lives at the very top
    <HousesProvider>
      <AppContent />
    </HousesProvider>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
