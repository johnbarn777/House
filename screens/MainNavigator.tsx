
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { StyleSheet } from 'react-native';

import HouseScreen from './HouseScreen';
import ChoresScreen from './ChoresScreen'; 
import SplitScreen from './SplitScreen';
import SettingsScreen from './SettingsScreen';  

const Tab = createBottomTabNavigator();

const MainNavigator = () => ( 
  <Tab.Navigator
    screenOptions={({ route }) => ({  
      tabBarIcon: ({ color, size }) => { 
        let iconName = '';  
        if (route.name === 'House') { 
          iconName = 'home'; 
        } else if (route.name === 'Chores') {  
          iconName = 'list'; 
        } else if (route.name === 'Split') {  
          iconName = 'payments';
        } else if (route.name === 'Settings') { 
          iconName = 'settings';    
        }  
        return <Icon name={iconName} size={size} color={color} />; 
      },  
      tabBarActiveTintColor: 'white',  
      tabBarInactiveTintColor: 'gray',  
      headerShown: false, 
      tabBarStyle: styles.tabBar, 
    })}  
  >  
    <Tab.Screen name="House" component={HouseScreen} />  
    <Tab.Screen name="Chores" component={ChoresScreen} />  
    <Tab.Screen name="Split" component={SplitScreen} />  
    <Tab.Screen name="Settings" component={SettingsScreen} />
  </Tab.Navigator>  
);

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

export default MainNavigator;