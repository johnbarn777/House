// components/HousesCard.js
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import firestore from '@react-native-firebase/firestore';
import Ionicons from 'react-native-vector-icons/Ionicons';

import { useHouses } from '../contexts/HousesContext';

const HousesCard = ({ userId, houses }) => {
  const { currentHouseId, setCurrentHouseId } = useHouses();

  const handleLeave = id => {
    Alert.alert(
      'Leave house?',
      'Are you sure you want to leave this house?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Leave',
          style: 'destructive',
          onPress: () => removeFromHouse(id),
        },
      ]
    );
  };

  const removeFromHouse = async houseId => {
    try {
      await firestore()
        .collection('houses')
        .doc(houseId)
        .update({
          members: firestore.FieldValue.arrayRemove(userId),
        });
      // If they just left the active house, clear selection
      if (houseId === currentHouseId) {
        setCurrentHouseId(null);
      }
    } catch {
      Alert.alert('Error', 'Could not leave house');
    }
  };

  const handleSelect = id => {
    setCurrentHouseId(id);
  };

  return (
    <View style={styles.card}>
      <Text style={styles.title}>Houses</Text>

      {houses.length === 0 ? (
        <Text style={styles.noHousesText}>You aren’t in any houses.</Text>
      ) : (
        houses.map(h => {
          const isActive = h.id === currentHouseId;
          return (
            <View
              key={h.id}
              style={[styles.houseItem, isActive && styles.activeHouseItem]}
            >
              <TouchableOpacity
                style={styles.houseNameContainer}
                onPress={() => handleSelect(h.id)}
              >
                <Text
                  style={[styles.houseName, isActive && styles.selectedText]}
                >
                  {h.houseName}
                </Text>
                {isActive && (
                  <Ionicons
                    name="checkmark"
                    size={18}
                    style={styles.checkIcon}
                  />
                )}
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.leaveButton}
                onPress={() => handleLeave(h.id)}
              >
                <Text style={styles.leaveButtonText}>Leave</Text>
              </TouchableOpacity>
            </View>
          );
        })
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#1a1a1a',
    borderRadius: 16,
    padding: 20,
  },
  title: {
    fontSize: 24,
    color: '#fff',
    marginBottom: 20,
    textAlign: 'center',
    fontFamily: 'Montserrat-Bold',
  },
  noHousesText: {
    color: '#fff',
    textAlign: 'center',
    fontFamily: 'Montserrat-Regular',
  },
  houseItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    padding: 8,
  },
  activeHouseItem: {
    backgroundColor: '#2a2a2a',
    borderRadius: 8,
  },
  houseNameContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  houseName: {
    color: '#fff',
    fontSize: 16,
    fontFamily: 'Montserrat-Regular',
  },
  selectedText: {
    color: '#ae00ff',
    fontFamily: 'Montserrat-Bold',
  },
  checkIcon: {
    marginLeft: 6,
    color: '#ae00ff',
  },
  leaveButton: {
    backgroundColor: '#ff4d4d',
    borderRadius: 12,
    paddingVertical: 8,
    paddingHorizontal: 16,
    marginLeft: 'auto',
  },
  leaveButtonText: {
    color: '#fff',
    fontFamily: 'Montserrat-Medium',
  },
});

export default HousesCard;
