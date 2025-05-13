import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { getAuth } from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';

const SettingsScreen = () => {
  const handleSignOut = async () => {
    try {
      await auth().signOut();
      // Sign-out successful
    } catch (error) {
      console.error("Error signing out: ", error);
    }
  };

  return (
    <View style={styles.screen}>
      <Text style={styles.text}>Settings</Text>
      <Button title="Sign Out" onPress={handleSignOut} color="#007bff" />
    </View>
  );
};

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
    marginBottom: 20,
  },
});

export default SettingsScreen;
