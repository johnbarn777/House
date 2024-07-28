// JoinHouseDialog.js

import React, { useState } from 'react';
import { View, TextInput, TouchableOpacity, Text, StyleSheet, Modal, Alert } from 'react-native';
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';

const JoinHouseDialog = ({ modalVisible, setModalVisible, setHouseData }) => {
  const [houseName, setHouseName] = useState('');
  const [houseCode, setHouseCode] = useState('');
  const user = auth().currentUser;

  const createHouse = async () => {
    if (!houseName) {
      Alert.alert('Error', 'Please enter a house name.');
      return;
    }

    try {
      const houseRef = await firestore().collection('houses').add({
        houseName,
        members: [user.uid]
      });

      Alert.alert('Success', `House created successfully! Your house code is: ${houseRef.id}`);
      setModalVisible(false);
      setHouseData({ houseName, members: [user.uid] });
    } catch (error) {
      console.error("Error creating house:", error);
      Alert.alert('Error', 'Could not create house. Please try again.');
    }
  };

  const joinHouse = async () => {
    if (!houseCode) {
      Alert.alert('Error', 'Please enter a house code.');
      return;
    }

    try {
      const houseRef = await firestore().collection('houses').doc(houseCode).get();

      if (houseRef.exists) {
        await firestore().collection('houses').doc(houseCode).update({
          members: firestore.FieldValue.arrayUnion(user.uid)
        });
        Alert.alert('Success', 'Joined house successfully!');
        setModalVisible(false);
        setHouseData(houseRef.data());
      } else {
        Alert.alert('Error', 'House not found.');
      }
    } catch (error) {
      console.error("Error joining house:", error);
      Alert.alert('Error', 'Could not join house. Please try again.');
    }
  };

  return (
    <Modal
      animationType="slide"
      transparent={true}
      visible={modalVisible}
      onRequestClose={() => {
        setModalVisible(!modalVisible);
      }}
    >
      <View style={styles.overlay}>
        <View style={styles.modalView}>
          <TextInput
            style={styles.input}
            placeholder="Enter House Name"
            placeholderTextColor="#888"
            value={houseName}
            onChangeText={setHouseName}
          />
          <TouchableOpacity style={styles.button} onPress={createHouse}>
            <Text style={styles.buttonText}>CREATE HOUSE</Text>
          </TouchableOpacity>
          <TextInput
            style={styles.input}
            placeholder="Enter House Code"
            placeholderTextColor="#888"
            value={houseCode}
            onChangeText={setHouseCode}
          />
          <TouchableOpacity style={styles.button} onPress={joinHouse}>
            <Text style={styles.buttonText}>JOIN HOUSE</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.button, styles.closeButton]} onPress={() => setModalVisible(!modalVisible)}>
            <Text style={styles.buttonText}>CLOSE</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)', // Dim background
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalView: {
    margin: 20,
    backgroundColor: 'black',
    borderRadius: 20,
    padding: 35,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 20,
    paddingHorizontal: 8,
    color: 'white',
    backgroundColor: '#333',
    width: '100%',
  },
  button: {
    backgroundColor: '#6a0dad', // Purple shade
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 20,
    marginVertical: 10,
    width: '100%',
    alignItems: 'center',
  },
  closeButton: {
    backgroundColor: '#8B0000', // Dark Red
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default JoinHouseDialog;
