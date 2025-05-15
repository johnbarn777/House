import React, { useState } from 'react';
import { SafeAreaView, View, Text, FlatList, TextInput, TouchableOpacity, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Ionicons from 'react-native-vector-icons/Ionicons';
import useChores from '../hooks/useChores';
import ChoreItem from '../components/ChoreItem';
import FrequencyPickerModal from '../components/FrequencyPickerModal';
import EditChoreModal from '../components/EditChoreModal';

const TAB_BAR_HEIGHT = 80;

const ChoresScreen = () => {
  const insets = useSafeAreaInsets();
  const {
    chores,
    loading,
    addChore,
    autoAssign,
    unassignAll,
    saveEdit,
    deleteChore
  } = useChores();

  // Add-Chore state
  const [newChore, setNewChore] = useState('');
  const [scheduleFreq, setScheduleFreq] = useState('Daily');
  const [scheduleCount, setScheduleCount] = useState('1');

  // Edit modal state
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingChore, setEditingChore] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editFreq, setEditFreq] = useState('Daily');
  const [editCount, setEditCount] = useState('1');

  const handleAdd = () => {
    const title = newChore.trim();
    const count = parseInt(scheduleCount, 10) || 1;
    if (!title) return;
    addChore(title, { frequency: scheduleFreq, count });
    setNewChore('');
  };

  const handleOpenEdit = chore => {
    setEditingChore(chore);
    setEditTitle(chore.title);
    setEditFreq(chore.schedule?.frequency ?? 'Daily');
    setEditCount(String(chore.schedule?.count ?? 1));
    setEditModalVisible(true);
  };

  const handleSave = () => {
    if (!editingChore) return;
    const count = parseInt(editCount, 10) || 1;
    saveEdit(editingChore.id, editTitle.trim(), { frequency: editFreq, count });
    setEditModalVisible(false);
    setEditingChore(null);
  };

  const handleDelete = id => deleteChore(id);

  const renderItem = ({ item }) => (
    <ChoreItem chore={item} onEdit={handleOpenEdit} onDelete={handleDelete} />
  );

  if (loading) {
    return (
      <SafeAreaView style={[styles.loadingContainer, { paddingTop: insets.top }]}>
        <Text style={styles.loadingText}>Loading chores...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[styles.container, { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.flex}
      >
        <View style={styles.buttonRow}>
          <TouchableOpacity style={styles.autoButton} onPress={autoAssign}>
            <Text style={styles.autoButtonText}>Auto-Assign</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.unassignButton} onPress={unassignAll}>
            <Text style={styles.unassignButtonText}>Unassign All</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.listContainer}>
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

          <FrequencyPickerModal
            value={scheduleFreq}
            onChange={setScheduleFreq}
          >
            <View style={[styles.input, styles.pickerToggle]}>
              <Text style={styles.pickerToggleText}>{scheduleFreq}</Text>
            </View>
          </FrequencyPickerModal>

          <TextInput
            style={[styles.input, styles.countInput]}
            placeholder="Count"
            keyboardType="numeric"
            placeholderTextColor="#888"
            value={scheduleCount}
            onChangeText={setScheduleCount}
          />

          <TouchableOpacity style={styles.addButton} onPress={handleAdd}>
            <Ionicons name="add-circle" size={36} color="#ae00ff" />
          </TouchableOpacity>
        </View>

        <EditChoreModal
          visible={editModalVisible}
          onClose={() => setEditModalVisible(false)}
          title={editTitle}
          onChangeTitle={setEditTitle}
          freq={editFreq}
          onChangeFreq={setEditFreq}
          count={editCount}
          onChangeCount={setEditCount}
          onSave={handleSave}
        />

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
  emptyContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  emptyText: { color: '#888', fontSize: 16 },
  inputContainer: { flexDirection: 'row', padding: 16, borderTopWidth: 1, borderColor: '#222', backgroundColor: '#000', alignItems: 'center' },
  input: { flex: 1, height: 48, backgroundColor: '#262626', borderRadius: 24, paddingHorizontal: 16, color: '#fff', marginRight: 8 },
  pickerToggle: { backgroundColor: '#262626', borderRadius: 24, justifyContent: 'center', paddingHorizontal: 16, marginRight: 8, height: 48 },
  pickerToggleText: { color: '#fff' },
  countInput: { width: 60, marginRight: 8 },
  addButton: { justifyContent: 'center' }
});

export default ChoresScreen;
