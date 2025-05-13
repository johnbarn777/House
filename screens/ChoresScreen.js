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
  Platform,
  Modal,
  TouchableWithoutFeedback
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Picker } from '@react-native-picker/picker';
import {
  getFirestore,
  collection,
  query,
  where,
  getDocs,
  orderBy,
  onSnapshot,
  addDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  doc as docRef
} from '@react-native-firebase/firestore';
import { getAuth } from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { Swipeable } from 'react-native-gesture-handler';

const TAB_BAR_HEIGHT = 80;

const ChoresScreen = () => {
  const insets = useSafeAreaInsets();
  const auth = getAuth(getApp());
  const user = auth.currentUser;
  const db = getFirestore(getApp());

  const [chores, setChores] = useState([]);
  const [newChore, setNewChore] = useState('');
  const [scheduleFreq, setScheduleFreq] = useState('Daily');
  const [scheduleCount, setScheduleCount] = useState('1');
  const [loading, setLoading] = useState(true);
  const [houseId, setHouseId] = useState(null);
  const [members, setMembers] = useState([]);
  const [showFreqPicker, setShowFreqPicker] = useState(false);

  // Edit modal state
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingChore, setEditingChore] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editFreq, setEditFreq] = useState('Daily');
  const [editCount, setEditCount] = useState('1');

  useEffect(() => {
    let unsubscribe = null;
    const init = async () => {
      try {
        const housesQ = query(
          collection(db, 'houses'),
          where('members', 'array-contains', user.uid)
        );
        const snap = await getDocs(housesQ);
        if (!snap.empty) {
          const doc = snap.docs[0];
          setHouseId(doc.id);
          setMembers(doc.data().members || []);
          const choresQ = query(
            collection(db, 'houses', doc.id, 'chores'),
            orderBy('createdAt', 'desc')
          );
          unsubscribe = onSnapshot(
            choresQ,
            qs => {
              setChores(qs.docs.map(d => ({ id: d.id, ...d.data() })));
              setLoading(false);
            },
            err => {
              console.error(err);
              setLoading(false);
            }
          );
        } else setLoading(false);
      } catch (e) {
        console.error(e);
        Alert.alert('Error', 'Could not load chores.');
        setLoading(false);
      }
    };
    init();
    return () => unsubscribe && unsubscribe();
  }, [user.uid]);

  const handleAddChore = async () => {
    const title = newChore.trim();
    const count = parseInt(scheduleCount, 10) || 1;
    if (!title || !houseId) return;
    try {
      await addDoc(
        collection(db, 'houses', houseId, 'chores'),
        { title, createdAt: serverTimestamp(), createdBy: user.uid, assignedTo: null, schedule: { frequency: scheduleFreq, count } }
      );
      setNewChore('');
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Could not add chore.');
    }
  };

  const handleAutoAssign = async () => {
    if (!houseId || members.length === 0) return;
    const unassigned = chores.filter(c => !c.assignedTo);
    try {
      await Promise.all(
        unassigned.map(c => updateDoc(
          docRef(db, 'houses', houseId, 'chores', c.id),
          { assignedTo: members[Math.floor(Math.random() * members.length)] }
        ))
      );
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Could not auto-assign chores.');
    }
  };

  const handleUnassignAll = async () => {
    if (!houseId) return;
    const assigned = chores.filter(c => c.assignedTo);
    try {
      await Promise.all(
        assigned.map(c => updateDoc(
          docRef(db, 'houses', houseId, 'chores', c.id),
          { assignedTo: null }
        ))
      );
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Could not unassign chores.');
    }
  };

  // Open edit modal
  const handleOpenEdit = (chore) => {
    setEditingChore(chore);
    setEditTitle(chore.title);
    // Use optional chaining in case schedule is undefined
    setEditFreq(chore.schedule?.frequency ?? 'Daily');
    setEditCount(String(chore.schedule?.count ?? 1));
    setEditModalVisible(true);
  };

  const handleSaveEdit = async () => {
    if (!editingChore) return;
    const count = parseInt(editCount, 10) || 1;
    try {
      await updateDoc(
        docRef(db, 'houses', houseId, 'chores', editingChore.id),
        { title: editTitle.trim(), 'schedule.frequency': editFreq, 'schedule.count': count }
      );
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Could not save changes.');
    }
    setEditModalVisible(false);
    setEditingChore(null);
  };

  const handleDeleteChore = async (id) => {
    try {
      await deleteDoc(docRef(db, 'houses', houseId, 'chores', id));
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Could not delete chore.');
    }
  };

  const renderRightActions = (chore) => (
    <View style={styles.actionsContainer}>
      <TouchableOpacity style={[styles.actionButton, styles.editButton]} onPress={() => handleOpenEdit(chore)}>
        <Text style={styles.actionText}>Edit</Text>
      </TouchableOpacity>
      <TouchableOpacity style={[styles.actionButton, styles.deleteButton]} onPress={() => handleDeleteChore(chore.id)}>
        <Text style={styles.actionText}>Delete</Text>
      </TouchableOpacity>
    </View>
  );

  const renderItem = ({ item }) => (
    <Swipeable renderRightActions={() => renderRightActions(item)}>
      <View style={styles.choreItem}>
        <Text style={styles.choreText}>{item.title}</Text>
        <Text style={styles.assignedText}>{item.assignedTo ? `Assigned to: ${item.assignedTo}` : 'Unassigned'}</Text>
        <Text style={styles.scheduleText}>{`${item.schedule.frequency} x ${item.schedule.count}`}</Text>
      </View>
    </Swipeable>
  );

  if (loading) return (
    <SafeAreaView style={[styles.loadingContainer, { paddingTop: insets.top }]}>  
      <Text style={styles.loadingText}>Loading chores...</Text>
    </SafeAreaView>
  );

  return (
    <SafeAreaView style={[styles.container, { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }]}>      
      <KeyboardAvoidingView behavior={Platform.OS==='ios'?'padding':'height'} style={styles.flex}>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={styles.autoButton} onPress={handleAutoAssign}><Text style={styles.autoButtonText}>Auto-Assign</Text></TouchableOpacity>
          <TouchableOpacity style={styles.unassignButton} onPress={handleUnassignAll}><Text style={styles.unassignButtonText}>Unassign All</Text></TouchableOpacity>
        </View>
        <View style={styles.listContainer}>
          {chores.length>0 ? <FlatList data={chores} renderItem={renderItem} keyExtractor={item=>item.id}/> : <View style={styles.emptyContainer}><Text style={styles.emptyText}>No chores yet. Add one!</Text></View>}
        </View>
        <View style={[styles.inputContainer,{marginBottom:insets.bottom||16}]}>  
          <TextInput style={styles.input} placeholder="New chore" placeholderTextColor="#888" value={newChore} onChangeText={setNewChore}/>
          <TouchableOpacity style={[styles.input,styles.pickerToggle]} onPress={()=>setShowFreqPicker(true)}><Text style={styles.pickerToggleText}>{scheduleFreq}</Text></TouchableOpacity>
          <TextInput style={[styles.input,styles.countInput]} placeholder="Count" keyboardType="numeric" placeholderTextColor="#888" value={scheduleCount} onChangeText={setScheduleCount}/>
          <TouchableOpacity style={styles.addButton} onPress={handleAddChore}><Ionicons name="add-circle" size={36} color="#ae00ff"/></TouchableOpacity>
        </View>

        {/* Frequency Picker Modal */}
        <Modal visible={showFreqPicker} transparent animationType="fade">
          <TouchableWithoutFeedback onPress={() => setShowFreqPicker(false)}>
            <View style={styles.modalOverlay}>
              <View style={styles.modalContent}>
                  <Picker selectedValue={scheduleFreq} onValueChange={v=>setScheduleFreq(v)}>
                    <Picker.Item label="Daily" value="Daily"/>
                    <Picker.Item label="Weekly" value="Weekly"/>
                    <Picker.Item label="Bi-weekly" value="Bi-weekly"/>
                    <Picker.Item label="Monthly" value="Monthly"/>
                  </Picker>
                  <TouchableOpacity style={styles.modalOkButton} onPress={()=>setShowFreqPicker(false)}><Text style={styles.modalOkText}>OK</Text></TouchableOpacity>
                </View>
            </View>
          </TouchableWithoutFeedback>
        </Modal>

        {/* Edit Chore Modal */}
        <Modal visible={editModalVisible} transparent animationType="slide">
          <TouchableWithoutFeedback onPress={() => setEditModalVisible(false)}>
            <View style={styles.modalOverlay}>
              <TouchableWithoutFeedback>
                <View style={styles.modalContent}>
                  <Text style={styles.modalTitle}>Edit Chore</Text>
                  <TextInput
                    style={styles.input}
                    value={editTitle}
                    onChangeText={setEditTitle}
                    placeholder="Chore title"
                    placeholderTextColor="#888"
                  />
                  <Picker selectedValue={editFreq} onValueChange={v=>setEditFreq(v)} style={styles.picker}>
                    <Picker.Item label="Daily" value="Daily"/>
                    <Picker.Item label="Weekly" value="Weekly"/>
                    <Picker.Item label="Bi-weekly" value="Bi-weekly"/>
                    <Picker.Item label="Monthly" value="Monthly"/>
                  </Picker>
                  <TextInput
                    style={[styles.input, styles.countInput]}
                    value={editCount}
                    onChangeText={setEditCount}
                    keyboardType="numeric"
                  />
                  <TouchableOpacity style={styles.modalOkButton} onPress={handleSaveEdit}><Text style={styles.modalOkText}>Save</Text></TouchableOpacity>
                </View>
              </TouchableWithoutFeedback>
            </View>
          </TouchableWithoutFeedback>
        </Modal>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  flex: { flex: 1 },
  container: { flex: 1, backgroundColor: '#0A0F1F' },
  loadingContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#0A0F1F' },
  loadingText: { color: '#fff', fontSize: 18 },
  buttonRow: { flexDirection: 'row', justifyContent: 'space-around', margin: 16 },
  autoButton: { backgroundColor: '#ae00ff', padding: 10, borderRadius: 8 },
  autoButtonText: { color: '#fff', fontWeight: '600' },
  unassignButton: { backgroundColor: '#555', padding: 10, borderRadius: 8 },
  unassignButtonText: { color: '#fff', fontWeight: '600' },
  listContainer: { flex: 1, padding: 16 },
  actionsContainer: { flexDirection: 'row', width: 160 },
  actionButton: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  editButton: { backgroundColor: '#aaa' },
  deleteButton: { backgroundColor: '#ff5252' },
  actionText: { color: '#fff', fontWeight: 'bold' },
  choreItem: { backgroundColor: '#1E1E1E', padding: 12, borderRadius: 8, marginBottom: 12 },
  choreText: { color: '#fff', fontSize: 16 },
  assignedText: { color: '#bbb', fontSize: 14, marginTop: 4 },
  scheduleText: { color: '#bbb', fontSize: 14, marginTop: 2 },
  emptyContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  emptyText: { color: '#888', fontSize: 16 },
  inputContainer: { flexDirection: 'row', padding: 16, borderTopWidth: 1, borderColor: '#222', backgroundColor: '#000', alignItems: 'center' },
  input: { flex: 1, height: 48, backgroundColor: '#262626', borderRadius: 24, paddingHorizontal: 16, color: '#fff', marginRight: 8 },
  pickerToggle: { backgroundColor: '#262626', borderRadius: 24, justifyContent: 'center', paddingHorizontal: 16, marginRight: 8, height: 48 },
  pickerToggleText: { color: '#fff' },
  countInput: { width: 60, marginRight: 8 },
  addButton: { justifyContent: 'center' },
  modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center' },
  modalContent: { width: '80%', backgroundColor: '#262626', borderRadius: 8, padding: 16 },
  modalOkButton: { marginTop: 8, padding: 10, backgroundColor: '#ae00ff', borderRadius: 8, alignItems: 'center' },
  modalOkText: { color: '#fff', fontWeight: '600' },
  modalTitle: { color: '#fff', fontSize: 18, marginBottom: 8, textAlign: 'center' },
  picker: { color: '#fff' }
});

export default ChoresScreen;
