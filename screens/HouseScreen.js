// HouseScreen.js (modular v22 API)
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
import {
  getFirestore,
  collection,
  doc as docRef,
  query,
  where,
  getDocs,
  orderBy,
  onSnapshot
} from '@react-native-firebase/firestore';
import { getAuth } from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import JoinHouseDialog from '../components/JoinHouseDialog';

const { width } = Dimensions.get('window');
const circleDiameter = width * 2;
const TAB_BAR_HEIGHT = 40; // adjust if needed

const HouseScreen = () => {
  const insets = useSafeAreaInsets();
  const [modalVisible, setModalVisible] = useState(false);
  const [houseData, setHouseData] = useState(null);
  const [chores, setChores] = useState([]);
  const [loading, setLoading] = useState(true);

  const auth = getAuth(getApp());
  const user = auth.currentUser;
  const db = getFirestore(getApp());

  useEffect(() => {
    let unsubscribe = null;
    const init = async () => {
      try {
        // fetch house document where user is member
        const housesQ = query(
          collection(db, 'houses'),
          where('members', 'array-contains', user.uid)
        );
        const snap = await getDocs(housesQ);
        if (!snap.empty) {
          const houseDoc = snap.docs[0];
          const data = { ...houseDoc.data(), code: houseDoc.id };
          setHouseData(data);

          // subscribe to chores subcollection
          const choresQ = query(
            collection(docRef(db, 'houses', houseDoc.id), 'chores'),
            orderBy('createdAt', 'desc')
          );
          unsubscribe = onSnapshot(choresQ, qs => {
            setChores(qs.docs.map(d => ({ id: d.id, ...d.data() })));
          }, err => console.error('Chores onSnapshot error:', err));
        }
      } catch (e) {
        console.error('Error fetching house/chores:', e);
        Alert.alert('Error', 'Could not load house data.');
      } finally {
        setLoading(false);
      }
    };
    init();
    return () => unsubscribe && unsubscribe();
  }, [user.uid]);

  if (loading) {
    return (
      <SafeAreaView style={[styles.loadingContainer, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>        
        <Text style={styles.loadingText}>Loading...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[styles.container, { paddingTop: insets.top }]}>      
      <ScrollView
        style={styles.container}
        contentContainerStyle={[styles.scrollContent, { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }]}
      >
        <View style={styles.circleContainer}>
          <View style={styles.circle}>
            <Text style={styles.houseName}>{houseData?.houseName || 'Start your House'}</Text>
            {houseData?.code && <Text style={styles.houseCode}>Code: {houseData.code}</Text>}
          </View>
        </View>

        {houseData && (
          <View style={styles.content}>
            <View style={styles.module}>
              <Text style={styles.moduleTitle}>Upcoming Chores</Text>
              {chores.length > 0 ? (
                chores.map(chore => (
                  <Text key={chore.id} style={styles.moduleContent}>- {chore.title}</Text>
                ))
              ) : (
                <Text style={styles.moduleContent}>No chores yet.</Text>
              )}
            </View>

            {/* Additional modules... */}
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
        )}
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
        setHouseData={setHouseData}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0A0F1F' },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: 'black' },
  loadingText: { color: 'white', fontSize: 18 },
  scrollContent: { flexGrow: 1 },
  circleContainer: { alignItems: 'center', height: width, marginBottom: -width / 2 },
  circle: { width: circleDiameter, height: circleDiameter, borderRadius: circleDiameter / 2, backgroundColor: 'white', justifyContent: 'flex-end', alignItems: 'center', position: 'absolute', bottom: 0, paddingBottom: circleDiameter / 4 },
  houseName: { fontSize: 24, color: 'black' },
  houseCode: { fontSize: 16, color: '#555', marginTop: 4 },
  content: { paddingTop: width / 2, paddingHorizontal: 16 },
  module: { backgroundColor: '#1E1E1E', borderRadius: 8, padding: 16, marginBottom: 16 },
  moduleTitle: { fontSize: 20, color: 'white', marginBottom: 8 },
  moduleContent: { fontSize: 16, color: 'white' },
  emptyContent: { flex: 1, paddingTop: width / 2 },
  addButton: { position: 'absolute', right: 20, backgroundColor: '#ae00ff', borderRadius: 50, padding: 10, zIndex: 1000, elevation: 1000 }
});

export default HouseScreen;
