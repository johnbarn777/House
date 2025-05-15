import { enableScreens } from 'react-native-screens';
enableScreens();

import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { getAuth } from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import AuthenticationScreen from './screens/AuthenticationScreen'; 
import MainNavigator from './screens/MainNavigator';
import { useAuth } from './hooks/useAuth'; // Import the useAuth hook

const Stack = createStackNavigator();

const App = () => {  
  const { user, initializing } = useAuth();
  

  if (initializing) {

    return (

      <View style={styles.loadingContainer}>

        <ActivityIndicator size="large" color="#0000ff" />

        <Text style={styles.loadingText}>Loading...</Text>

      </View>

    );

  }

  return (  
    <NavigationContainer>  
     <Stack.Navigator screenOptions={{ headerShown: false }}>
        {user ? (  
          <Stack.Screen name="Main" component={MainNavigator} />  
        ) : (
          <Stack.Screen name="Auth" component={AuthenticationScreen} />  
        )}  
      </Stack.Navigator>   
    </NavigationContainer>  
  );  
}  

const styles = StyleSheet.create({
  loadingContainer: {

    flex: 1,

    justifyContent: 'center',

    alignItems: 'center',

  },

  loadingText: {

    marginTop: 10,

    fontSize: 18,

  },
  tabBar: {
    backgroundColor: '#000814',
    borderTopColor: 'transparent',
    position: 'absolute',
    bottom: 0,
    padding: 10,
    height: 70,
    justifyContent: 'center',
  },
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
});

export default App;
