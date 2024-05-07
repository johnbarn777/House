import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';  // Import Icon

const Tab = createBottomTabNavigator();

const HouseScreen = () => (
  <View style={styles.screen}>
    <Text style={styles.text}>House</Text>
  </View>
);

const TasksScreen = () => (
  <View style={styles.screen}>
    <Text style={styles.text}>Tasks</Text>
  </View>
);

const SplitScreen = () => (
  <View style={styles.screen}>
    <Text style={styles.text}>Split</Text>
  </View>
);

const SettingsScreen = () => (
  <View style={styles.screen}>
    <Text style={styles.text}>Settings</Text>
  </View>
);

export default function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={({ route }) => ({
          tabBarIcon: ({ focused, color, size }) => {
            let iconName = ''; // Add a default value for iconName
            if (route.name === 'House') {
              iconName = 'home'; // Change as appropriate
            } else if (route.name === 'Tasks') {
              iconName = 'list'; // Change as appropriate
            } else if (route.name === 'Split') {
              iconName = 'payments'; // Change as appropriate
            } else if (route.name === 'Settings') {
              iconName = 'settings'; // Change as appropriate
            }

            // You can return any component that you like here!
            return <Icon name={iconName} size={size} color={color} />;
          },
          tabBarActiveTintColor: 'white',
          tabBarInactiveTintColor: 'gray',
          headerShown: false,
          tabBarStyle: styles.tabBar,
        })}
      >
        <Tab.Screen name="House" component={HouseScreen} />
        <Tab.Screen name="Tasks" component={TasksScreen} />
        <Tab.Screen name="Split" component={SplitScreen} />
        <Tab.Screen name="Settings" component={SettingsScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'black',
  },
  text: {
    color: 'white',
    fontSize: 20,
  },
  tabBar: {
    backgroundColor: '#000814', // Dark blue, close to black
    borderTopColor: 'transparent',
    position: 'absolute',
    bottom: 0,
    padding: 10,
    height: 70, // Adjust based on accessibility needs
    justifyContent: 'center',
  }
});
