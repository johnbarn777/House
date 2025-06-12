// components/HousesCard.js
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import firestore from '@react-native-firebase/firestore';

const HousesCard = ({ userId, houses }) => {
  const handleLeave = id => {
    Alert.alert('Leave house?', 'Are you sure you want to leave this house?', [
      { text:'Cancel', style:'cancel' },
      { text:'Leave', style:'destructive', onPress:() => removeFromHouse(id) }
    ]);
  };

  const removeFromHouse = async houseId => {
    try {
      await firestore().collection('houses').doc(houseId).update({
        members: firestore.FieldValue.arrayRemove(userId)
      });
    } catch {
      Alert.alert('Error', 'Could not leave house');
    }
  };

  return (
    <View style={styles.card}>
      <Text style={styles.title}>Houses</Text>
      {houses.length === 0 ? (
        <Text style={styles.noHousesText}>You aren’t in any houses.</Text>
      ) : (
        houses.map(h => (
          <View key={h.id} style={styles.houseItem}>
            <Text style={styles.houseName}>{h.houseName}</Text>
            <TouchableOpacity style={styles.leaveButton} onPress={()=>handleLeave(h.id)}>
              <Text style={styles.leaveButtonText}>Leave</Text>
            </TouchableOpacity>
          </View>
        ))
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  card:{ backgroundColor:'#1a1a1a', borderRadius:16, padding:20 },
  title:{ fontSize:24, color:'#fff', marginBottom:20, textAlign:'center', fontFamily:'Montserrat-Bold' },
  noHousesText:{ color:'#fff', textAlign:'center', fontFamily:'Montserrat-Regular' },
  houseItem:{ flexDirection:'row', alignItems:'center', marginBottom:12 },
  houseName:{ color:'#fff', fontSize:16, fontFamily:'Montserrat-Regular' },
  leaveButton:{ backgroundColor:'#ff4d4d', borderRadius:12, paddingVertical:8, paddingHorizontal:16, marginLeft:'auto' },
  leaveButtonText:{ color:'#fff', fontFamily:'Montserrat-Medium' },
});

export default HousesCard;