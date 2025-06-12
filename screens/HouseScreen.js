// HouseScreen.js
import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  StyleSheet,
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

const { width } = Dimensions.get('window');
const circleDiameter = width * 2;
const TAB_BAR_HEIGHT = 40;

const HouseScreen = ({ route, navigation }) => {
  const insets = useSafeAreaInsets();
  const houses = useHouses();

  // Safely get houseId: prefer route param, fallback to first house
  const paramId = route?.params?.houseId;
  const fallbackId = houses.length > 0 ? houses[0].id : null;
  const houseId = paramId || fallbackId;

  // Find current house data
  const houseData = houses.find(h => h.id === houseId);

  const [modalVisible, setModalVisible] = useState(false);
  const [chores, setChores] = useState([]);

  // Redirect if no house selected
  useEffect(() => {
    if (!houseId) {
      Alert.alert('No house selected', 'Please join or select a house.', [
        { text: 'OK', onPress: () => navigation.goBack() }
      ]);
    }
  }, [houseId, navigation]);

  // If user left the house
  useEffect(() => {
    if (houseId && houseData === undefined) {
      Alert.alert(
        "You've left this house",
        'Returning to your houses list.',
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    }
  }, [houseData, houseId, navigation]);

  // Subscribe to chores
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

  // While selecting or loading
  if (!houseId || (houseId && houseData === undefined)) {
    return (
      <SafeAreaView style={styles.loadingContainer}>
        <Text style={styles.loadingText}>Loading House...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>      
      <ScrollView
        style={styles.container}
        contentContainerStyle={[
          styles.scrollContent,
          { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }
        ]}
      >
        <View style={styles.circleContainer}>
          <View style={styles.circle}>
            <Text style={styles.houseName}>{houseData.houseName}</Text>
            <Text style={styles.houseCode}>Code: {houseData.id}</Text>
          </View>
        </View>

        <View style={styles.content}>
          <View style={styles.module}>
            <Text style={styles.moduleTitle}>Upcoming Chores</Text>
            {chores.length > 0 ? (
              chores.map(chore => (
                <Text key={chore.id} style={styles.moduleContent}>
                  - {chore.title}
                </Text>
              ))
            ) : (
              <Text style={styles.moduleContent}>No chores yet.</Text>
            )}
          </View>
          {/* Additional modules here... */}
        </View>
      </ScrollView>

      <TouchableOpacity
        style={[styles.addButton, { bottom: insets.bottom + TAB_BAR_HEIGHT }]}
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

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0A0F1F' },
  scrollContent: { flexGrow: 1 },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: 'black' },
  loadingText: { color: 'white', fontSize: 18 },
  circleContainer: { alignItems: 'center', height: width, marginBottom: -width / 2 },
  circle: { width: circleDiameter, height: circleDiameter, borderRadius: circleDiameter / 2, backgroundColor: 'white', justifyContent: 'flex-end', alignItems: 'center', position: 'absolute', bottom: 0, paddingBottom: circleDiameter / 4 },
  houseName: { fontSize: 24, color: 'black' },
  houseCode: { fontSize: 16, color: '#555', marginTop: 4 },
  content: { paddingTop: width / 2, paddingHorizontal: 16 },
  module: { backgroundColor: '#1E1E1E', borderRadius: 8, padding: 16, marginBottom: 16 },
  moduleTitle: { fontSize: 20, color: 'white', marginBottom: 8 },
  moduleContent: { fontSize: 16, color: 'white' },
  addButton: { position: 'absolute', right: 20, backgroundColor: '#ae00ff', borderRadius: 50, padding: 10, zIndex: 1000, elevation: 1000 }
});

export default HouseScreen;
