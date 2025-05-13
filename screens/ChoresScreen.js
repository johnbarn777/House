import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';
import Ionicons from 'react-native-vector-icons/Ionicons';

const ChoresScreen = () => {
  const insets = useSafeAreaInsets();
  const [chores, setChores] = useState([]);
  const [newChore, setNewChore] = useState('');
  const [loading, setLoading] = useState(true);
  const [houseCode, setHouseCode] = useState(null);
  const user = auth().currentUser;

  useEffect(() => {
    let unsubscribe = null;

    const initChores = async () => {
      const snap = await firestore()
        .collection('houses')
        .where('members', 'array-contains', user.uid)
        .get();

      if (!snap.empty) {
        const doc = snap.docs[0];
        setHouseCode(doc.id);

        unsubscribe = firestore()
          .collection('houses')
          .doc(doc.id)
          .collection('chores')
          .orderBy('createdAt', 'desc')
          .onSnapshot(querySnapshot => {
            const list = [];
            querySnapshot.forEach(choreDoc => {
              list.push({ id: choreDoc.id, ...choreDoc.data() });
            });
            setChores(list);
            setLoading(false);
          }, error => {
            console.error('Chores snapshot error:', error);
            setLoading(false);
          });
      } else {
        setLoading(false);
      }
    };

    initChores();
    return () => { if (unsubscribe) unsubscribe(); };
  }, [user]);

  const handleAddChore = async () => {
    if (!newChore.trim()) return;
    try {
      await firestore()
        .collection('houses')
        .doc(houseCode)
        .collection('chores')
        .add({
          title: newChore.trim(),
          createdAt: firestore.FieldValue.serverTimestamp(),
          createdBy: user.uid
        });
      setNewChore('');
    } catch (e) {
      Alert.alert('Error', 'Could not add chore.');
    }
  };

  const renderItem = ({ item }) => (
    <View style={styles.choreItem}>
      <Text style={styles.choreText}>{item.title}</Text>
    </View>
  );

  if (loading) {
    return (
      <SafeAreaView style={[styles.loadingContainer, { paddingTop: insets.top }]}>  
        <Text style={styles.loadingText}>Loading chores...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[styles.container, { paddingBottom: insets.bottom }]}>      
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.flex}
      >
        <View style={[styles.listContainer, { paddingBottom: insets.bottom + 80 }]}>  
          {chores.length > 0 ? (
            <FlatList
              data={chores}
              renderItem={renderItem}
              keyExtractor={item => item.id}
            />
          ) : (
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>No chores yet. Add one!</Text>
            </View>
          )}
        </View>

        <View style={[styles.inputContainer, { marginBottom: insets.bottom || 16 }]}>  
          <TextInput
            style={styles.input}
            placeholder="New chore"
            placeholderTextColor="#888"
            value={newChore}
            onChangeText={setNewChore}
          />
          <TouchableOpacity style={styles.addButton} onPress={handleAddChore}>
            <Ionicons name="add-circle" size={36} color="#ae00ff" />
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  flex: { flex: 1 },
  container: { flex: 1, backgroundColor: '#0A0F1F' },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#0A0F1F' },
  loadingText: { color: '#fff', fontSize: 18 },
  listContainer: { flex: 1, padding: 16 },
  choreItem: { backgroundColor: '#1E1E1E', padding: 12, borderRadius: 8, marginBottom: 12 },
  choreText: { color: '#fff', fontSize: 16 },
  emptyContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  emptyText: { color: '#888', fontSize: 16 },
  inputContainer: { flexDirection: 'row', padding: 16, borderTopWidth: 1, borderColor: '#222', backgroundColor: '#000' },
  input: { flex: 1, height: 48, backgroundColor: '#262626', borderRadius: 24, paddingHorizontal: 16, color: '#fff' },
  addButton: { justifyContent: 'center', marginLeft: 12 }
});

export default ChoresScreen;
