// HouseScreen.js
import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  Dimensions,
  ScrollView,
  TouchableOpacity,
  Alert
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Icon from 'react-native-vector-icons/MaterialIcons';
import firestore from '@react-native-firebase/firestore';
import { useHouses } from '../src/contexts/HousesContext';
import JoinHouseDialog from '../src/components/JoinHouseDialog';

import CommonStyles from '../src/styles/CommonStyles';

const { width } = Dimensions.get('window');
const TAB_BAR_HEIGHT = 40;

const HouseScreen = ({ route, navigation }) => {
  const insets = useSafeAreaInsets();
  const houses = useHouses();

  const paramId = route?.params?.houseId;
  const fallbackId = houses.length > 0 ? houses[0].id : null;
  const houseId = paramId || fallbackId;
  const houseData = houses.find(h => h.id === houseId);

  const [modalVisible, setModalVisible] = useState(false);
  const [chores, setChores] = useState([]);

  useEffect(() => {
    if (!houseId) {
      Alert.alert('No house selected', 'Please join or select a house.', [
        { text: 'OK', onPress: () => navigation.goBack() }
      ]);
    }
  }, [houseId, navigation]);

  useEffect(() => {
    if (houseId && houseData === undefined) {
      Alert.alert(
        "You've left this house",
        'Returning to your houses list.',
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    }
  }, [houseData, houseId, navigation]);

  useEffect(() => {
    if (!houseId) return;
    const unsubscribe = firestore()
      .collection('houses')
      .doc(houseId)
      .collection('chores')
      .orderBy('createdAt', 'desc')
      .onSnapshot(
        snap => setChores(snap.docs.map(d => ({ id: d.id, ...d.data() }))),
        err => console.error('Chores subscription error:', err)
      );
    return () => unsubscribe();
  }, [houseId]);

  if (!houseId || (houseId && houseData === undefined)) {
    return (
      <SafeAreaView style={[CommonStyles.safe, CommonStyles.centerContent, { paddingTop: insets.top }]}>        
        <Text style={CommonStyles.loadingText}>Loading House...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[CommonStyles.safe, { paddingTop: insets.top }]}>      
      <ScrollView
        style={CommonStyles.flex}
        contentContainerStyle={[CommonStyles.scrollFlexGrow, { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }]}
      >
        <View style={CommonStyles.circleContainer}>
          <View style={CommonStyles.circle}>
            <Text style={CommonStyles.houseName}>{houseData.houseName}</Text>
            <Text style={CommonStyles.houseCode}>Code: {houseData.id}</Text>
          </View>
        </View>

        <View style={CommonStyles.content}>
          <View style={CommonStyles.module}>
            <Text style={CommonStyles.moduleTitle}>Upcoming Chores</Text>
            {chores.length > 0 ? (
              chores.map(chore => (
                <Text key={chore.id} style={CommonStyles.moduleContent}>
                  - {chore.title}
                </Text>
              ))
            ) : (
              <Text style={CommonStyles.moduleContent}>No chores yet.</Text>
            )}
          </View>
          {/* Additional modules here... */}
        </View>
      </ScrollView>

      <TouchableOpacity
        style={[CommonStyles.addButton, { bottom: insets.bottom + TAB_BAR_HEIGHT }]}
        onPress={() => setModalVisible(true)}
      >
        <Icon name="plus" size={30} color="white" />
      </TouchableOpacity>

      <JoinHouseDialog
        modalVisible={modalVisible}
        setModalVisible={setModalVisible}
      />
    </SafeAreaView>
  );
};

export default HouseScreen;
