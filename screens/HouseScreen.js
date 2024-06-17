import React from 'react';
import { View, Text, StyleSheet, Dimensions, ScrollView } from 'react-native';

const HouseScreen = () => {
  const houseName = "Your House"; // You can replace this with dynamic data if needed

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.scrollContent}>
      <View style={styles.circleContainer}>
        <View style={styles.circle}>
          <Text style={styles.houseName}>{houseName}</Text>
        </View>
      </View>
      <View style={styles.content}>
        <View style={styles.module}>
          <Text style={styles.moduleTitle}>Upcoming Tasks</Text>
          <Text style={styles.moduleContent}>- Task 1</Text>
          <Text style={styles.moduleContent}>- Task 2</Text>
          <Text style={styles.moduleContent}>- Task 3</Text>
        </View>
        <View style={styles.module}>
          <Text style={styles.moduleTitle}>Recent House Purchases</Text>
          <Text style={styles.moduleContent}>- Purchase 1</Text>
          <Text style={styles.moduleContent}>- Purchase 2</Text>
          <Text style={styles.moduleContent}>- Purchase 3</Text>
        </View>
        <View style={styles.module}>
          <Text style={styles.moduleTitle}>Integrations</Text>
          <Text style={styles.moduleContent}>- Integration 1</Text>
          <Text style={styles.moduleContent}>- Integration 2</Text>
          <Text style={styles.moduleContent}>- Integration 3</Text>
        </View>
      </View>
    </ScrollView>
  );
};

const { width } = Dimensions.get('window');
const circleDiameter = width * 2; // Adjust this value to control the size of the circle

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
  },
  scrollContent: {
    flexGrow: 1,
    paddingBottom: 70,
  },
  circleContainer: {
    alignItems: 'center',
    height: width, // Adjust the height to ensure it fits within the top part
    marginBottom: -width / 2, // Negative margin to position content correctly
  },
  circle: {
    width: circleDiameter,
    height: circleDiameter,
    borderRadius: circleDiameter / 2,
    backgroundColor: 'white',
    justifyContent: 'flex-end', // Align content to the bottom of the circle
    alignItems: 'center',
    position: 'absolute',
    bottom: 0,
    paddingBottom: circleDiameter / 4, // Add padding to move text upwards within the bottom half
  },
  houseName: {
    fontSize: 24,
    color: 'black',
  },
  content: {
    paddingTop: width / 2, // Padding to ensure content starts below the circle
    paddingHorizontal: 16,
  },
  module: {
    backgroundColor: '#1E1E1E',
    borderRadius: 8,
    padding: 16,
    marginBottom: 16,
  },
  moduleTitle: {
    fontSize: 20,
    color: 'white',
    marginBottom: 8,
  },
  moduleContent: {
    fontSize: 16,
    color: 'white',
  },
});

export default HouseScreen;
