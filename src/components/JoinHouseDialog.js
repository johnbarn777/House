// JoinHouseDialog.js
import React, { useState, useEffect } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  Modal,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
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

const JoinHouseDialog = ({ modalVisible, setModalVisible }) => {
  const insets = useSafeAreaInsets();
  const [houseName, setHouseName] = useState('');
  const [houseCode, setHouseCode] = useState('');
  const [user, setUser] = useState(null);
  const [authLoaded, setAuthLoaded] = useState(false);

  // Listen for auth state
  useEffect(() => {
    const unsubscribe = auth().onAuthStateChanged(u => {
      setUser(u);
      setAuthLoaded(true);
    });
    return unsubscribe;
  }, []);

  const createHouse = async () => {
    if (!houseName.trim()) {
      return Alert.alert('Error', 'Please enter a house name.');
    }
    if (!user) {
      return Alert.alert('Error', 'You must be signed in to create a house.');
    }

    let newCode;
    let created = false;

    while (!created) {
      newCode = generateHouseCode();
      const docRef = firestore().collection('houses').doc(newCode);

      try {
        await docRef.create({
          houseName: houseName.trim(),
          members: [user.uid],
        });
        created = true;
      } catch (e) {
        if (
          e.code === 'already-exists' ||
          e.message?.includes('already exists')
        ) {
          continue;
        }
        console.error('Error creating house:', e);
        return Alert.alert(
          'Error',
          'Could not create house. Please try again.'
        );
      }
    }

    Alert.alert(
      'Success',
      `House created! Your house code is: ${newCode}`
    );
    setModalVisible(false);
  };

  const joinHouse = async () => {
    const codePattern = /^[A-Za-z0-9]{6}$/;
    if (!codePattern.test(houseCode)) {
      return Alert.alert(
        'Error',
        'House code must be exactly 6 alphanumeric characters.'
      );
    }
    if (!user) {
      return Alert.alert('Error', 'You must be signed in to join a house.');
    }
    try {
      const docRef = firestore().collection('houses').doc(houseCode);
      const doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({
          members: firestore.FieldValue.arrayUnion(user.uid),
        });
        Alert.alert('Success', 'Joined house successfully!');
        setModalVisible(false);
      } else {
        Alert.alert('Error', 'House not found.');
      }
    } catch (error) {
      console.error('Error joining house:', error);
      Alert.alert(
        'Error',
        'Could not join house. Please try again.'
      );
    }
  };

  return (
    <Modal
      animationType="slide"
      transparent
      visible={modalVisible}
      onRequestClose={() => setModalVisible(false)}
      presentationStyle="overFullScreen"
      statusBarTranslucent
    >
      <View
        style={[
          styles.overlay,
          {
            paddingTop: insets.top,
            paddingBottom: insets.bottom,
          },
        ]}
      >
        <View
          style={[
            styles.modalView,
            {
              marginTop: insets.top + 20,
              marginBottom: insets.bottom + 20,
            },
          ]}
        >
          {!authLoaded ? (
            <ActivityIndicator size="large" color="#6a0dad" />
          ) : (
            <>
              <TextInput
                style={styles.input}
                placeholder="Enter House Name"
                placeholderTextColor="#888"
                value={houseName}
                onChangeText={setHouseName}
                editable={!!user}
              />
              <TouchableOpacity
                style={[
                  styles.button,
                  !user && styles.disabledButton,
                ]}
                onPress={createHouse}
                disabled={!user}
              >
                <Text style={styles.buttonText}>
                  CREATE HOUSE
                </Text>
              </TouchableOpacity>

              <TextInput
                style={styles.input}
                placeholder="Enter House Code"
                placeholderTextColor="#888"
                value={houseCode}
                onChangeText={text =>
                  setHouseCode(
                    text.replace(/[^A-Za-z0-9]/g, '')
                  )
                }
                maxLength={6}
                autoCapitalize="characters"
                editable={!!user}
              />
              <TouchableOpacity
                style={[
                  styles.button,
                  !user && styles.disabledButton,
                ]}
                onPress={joinHouse}
                disabled={!user}
              >
                <Text style={styles.buttonText}>
                  JOIN HOUSE
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.button,
                  styles.closeButton,
                ]}
                onPress={() => setModalVisible(false)}
              >
                <Text style={styles.buttonText}>
                  CLOSE
                </Text>
              </TouchableOpacity>
            </>
          )}
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalView: {
    width: '90%',
    backgroundColor: 'black',
    borderRadius: 20,
    padding: 35,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
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
    backgroundColor: '#6a0dad',
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 20,
    marginVertical: 10,
    width: '100%',
    alignItems: 'center',
  },
  disabledButton: {
    backgroundColor: '#444',
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
