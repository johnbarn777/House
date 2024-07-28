// HouseScreen.js

import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Dimensions, ScrollView, TouchableOpacity, Alert } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';
import JoinHouseDialog from '../components/JoinHouseDialog';

const HouseScreen = () => {
  const [modalVisible, setModalVisible] = useState(false);
  const [houseData, setHouseData] = useState(null);
  const [loading, setLoading] = useState(true);
  const user = auth().currentUser;

  useEffect(() => {
    const fetchHouseData = async () => {
      const housesRef = await firestore().collection('houses').where('members', 'array-contains', user.uid).get();
      if (!housesRef.empty) {
        setHouseData(housesRef.docs[0].data());
      }
      setLoading(false);
    };

    fetchHouseData();
  }, [user]);

  if (loading) {
    return (
      <View style={styles.container}>
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.scrollContent}>
      <View style={styles.circleContainer}>
        <View style={styles.circle}>
          <Text style={styles.houseName}>{houseData ? houseData.houseName : 'Start your House'}</Text>
        </View>
      </View>
      {houseData ? (
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
      ) : (
        <View style={styles.emptyContent} />
      )}
      <TouchableOpacity style={styles.addButton} onPress={() => setModalVisible(true)}>
        <Icon name="add" size={30} color="white" />
      </TouchableOpacity>
      <JoinHouseDialog
        modalVisible={modalVisible}
        setModalVisible={setModalVisible}
        setHouseData={setHouseData}
      />
    </ScrollView>
  );
};

const { width } = Dimensions.get('window');
const circleDiameter = width * 2;

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
    height: width,
    marginBottom: -width / 2,
  },
  circle: {
    width: circleDiameter,
    height: circleDiameter,
    borderRadius: circleDiameter / 2,
    backgroundColor: 'white',
    justifyContent: 'flex-end',
    alignItems: 'center',
    position: 'absolute',
    bottom: 0,
    paddingBottom: circleDiameter / 4,
  },
  houseName: {
    fontSize: 24,
    color: 'black',
  },
  content: {
    paddingTop: width / 2,
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
  emptyContent: {
    flex: 1,
    paddingTop: width / 2,
  },
  addButton: {
    position: 'absolute',
    top: 40,
    right: 20,
    backgroundColor: '#007bff',
    borderRadius: 50,
    padding: 10,
  },
  loadingText: {
    fontSize: 18,
    color: 'white',
  },
});

export default HouseScreen;
