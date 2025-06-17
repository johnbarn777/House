// HouseScreen.js
import React, { useState, useEffect, useRef } from 'react';
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
import MaterialIcon from 'react-native-vector-icons/MaterialIcons';
import firestore from '@react-native-firebase/firestore';
import { useHouses } from '../src/contexts/HousesContext';
import JoinHouseDialog from '../src/components/JoinHouseDialog';

import CommonStyles from '../src/styles/CommonStyles';

const { width } = Dimensions.get('window');
const TAB_BAR_HEIGHT = 40;

const HouseScreen = ({ route, navigation }) => {
  const insets = useSafeAreaInsets();
  const { houses, currentHouseId } = useHouses(); //houses = useHouses();

  // track first render to avoid false alerts
  const initialMount = useRef(true);
  const initialDataCheck = useRef(true);

  // Determine current house ID
   const paramId    = route?.params?.houseId;
  const houseId    = paramId || currentHouseId;
  const houseData  = houses.find(h => h.id === houseId);

  const [modalVisible, setModalVisible] = useState(false);
  const [chores, setChores] = useState([]);

  // Navigation helper
  const goToHouseList = () => {
    if (navigation.canGoBack()) {
      navigation.goBack();
    } else {
      navigation.navigate('HouseList');
    }
  };

  // Alert if no house selected; skip if navigated with paramId or on initial mount
  useEffect(() => {
    if (paramId) return;
    if (initialMount.current) {
      initialMount.current = false;
      return;
    }
    if (!houseId) {
      Alert.alert('No house selected', 'Please join or select a house.', [
        { text: 'OK', onPress: goToHouseList }
      ]);
    }
  }, [paramId, houseId]);

  // Alert when user leaves the house; skip initial data
  useEffect(() => {
    if (initialDataCheck.current) {
      initialDataCheck.current = false;
      return;
    }
    if (houseId && houseData === undefined) {
      Alert.alert(
        "You've left this house",
        'Returning to your houses list.',
        [{ text: 'OK', onPress: goToHouseList }]
      );
    }
  }, [houseData, houseId]);

  // Subscribe to chores for the current house
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
        <MaterialIcon name="add" size={30} color="white" />
      </TouchableOpacity>

      <JoinHouseDialog
        modalVisible={modalVisible}
        setModalVisible={setModalVisible}
      />
    </SafeAreaView>
  );
};

export default HouseScreen;
