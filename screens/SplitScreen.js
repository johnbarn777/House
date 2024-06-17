import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const SplitScreen = () => (
  <View style={styles.screen}>
    <Text style={styles.text}>Split</Text>
  </View>
);

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
});

export default SplitScreen;
