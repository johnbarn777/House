import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { StyleSheet } from 'react-native';
import auth from '@react-native-firebase/auth';
import AuthenticationScreen from './screens/AuthenticationScreen'; 
import MainNavigator from './screens/MainNavigator';

const Stack = createStackNavigator();

const App = () => {  
  const [initializing, setInitializing] = useState(true);  
  const [user, setUser] = useState(null);  

  useEffect(() => {  
    const subscriber = auth().onAuthStateChanged((user) => {  
      setUser(user);  
      if (initializing) setInitializing(false);  
    });  
    return subscriber; // unsubscribe on unmount  
  }, [initializing]);  // Ensure `initializing` is in the dependency array

  if (initializing) return null;  

  return (  
    <NavigationContainer>  
      <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Main" component={MainNavigator} /> 
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
