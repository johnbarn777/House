// JoinHouseDialog.js

import React, { useState } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  Modal,
  Alert
} from 'react-native';
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';

// Helper to generate a 6-character alphanumeric code
const generateHouseCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
};

const JoinHouseDialog = ({ modalVisible, setModalVisible, setHouseData }) => {
  const [houseName, setHouseName] = useState('');
  const [houseCode, setHouseCode] = useState('');
  const user = auth().currentUser;

  /**
   * Creates a new house with a unique 6-character code.
   * Ensures no collision by checking Firestore for existing docs.
   */
  const createHouse = async () => {
    if (!houseName.trim()) {
      Alert.alert('Error', 'Please enter a house name.');
      return;
    }

    try {
      // Generate a non-colliding code
      let newCode;
      let exists = true;
      while (exists) {
        newCode = generateHouseCode();
        const doc = await firestore().collection('houses').doc(newCode).get();
        exists = doc.exists;
      }

      // Create document with code as ID
      await firestore()
        .collection('houses')
        .doc(newCode)
        .set({
          houseName: houseName.trim(),
          members: [user.uid]
        });

      Alert.alert('Success', `House created! Your house code is: ${newCode}`);
      setModalVisible(false);
      // Pass back the new house data including code
      setHouseData({ houseName: houseName.trim(), members: [user.uid], code: newCode });
    } catch (error) {
      console.error('Error creating house:', error);
      Alert.alert('Error', 'Could not create house. Please try again.');
    }
  };

  /**
   * Joins an existing house by code.
   */
  const joinHouse = async () => {
    const codePattern = /^[A-Za-z0-9]{6}$/;
    if (!codePattern.test(houseCode)) {
      Alert.alert('Error', 'House code must be exactly 6 alphanumeric characters.');
      return;
    }

    try {
      const docRef = firestore().collection('houses').doc(houseCode);
      const doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          members: firestore.FieldValue.arrayUnion(user.uid)
        });

        Alert.alert('Success', 'Joined house successfully!');
        setModalVisible(false);
        setHouseData({ ...doc.data(), code: houseCode });
      } else {
        Alert.alert('Error', 'House not found.');
      }
    } catch (error) {
      console.error('Error joining house:', error);
      Alert.alert('Error', 'Could not join house. Please try again.');
    }
  };

  return (
    <Modal
      animationType="slide"
      transparent
      visible={modalVisible}
      onRequestClose={() => setModalVisible(false)}
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
            onChangeText={text => setHouseCode(text.replace(/[^A-Za-z0-9]/g, ''))}
            maxLength={6}
            autoCapitalize="characters"
          />
          <TouchableOpacity style={styles.button} onPress={joinHouse}>
            <Text style={styles.buttonText}>JOIN HOUSE</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.closeButton]}
            onPress={() => setModalVisible(false)}
          >
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
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
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
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
    width: '90%'
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
    backgroundColor: '#6a0dad',
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 20,
    marginVertical: 10,
    width: '100%',
    alignItems: 'center',
  },
  closeButton: {
    backgroundColor: '#8B0000',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default JoinHouseDialog;
