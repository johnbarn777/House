// ChoresScreen.js
import React, { useState } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { useHouses } from '../src/contexts/HousesContext';
import useChores from '../src/hooks/useChores';
import ChoreItem from '../src/components/ChoreItem';
import FrequencyPickerModal from '../src/components/FrequencyPickerModal';
import EditChoreModal from '../src/components/EditChoreModal';

import CommonStyles from '../src/styles/CommonStyles';

const TAB_BAR_HEIGHT = 80;

const ChoresList = ({ houseId }) => {
  const insets = useSafeAreaInsets();
  const { chores, loading, addChore, saveEdit, deleteChore } = useChores(houseId);

  const [newChore, setNewChore] = useState('');
  const [scheduleFreq, setScheduleFreq] = useState('Daily');
  const [scheduleCount, setScheduleCount] = useState('1');

  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingChore, setEditingChore] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editFreq, setEditFreq] = useState('Daily');
  const [editCount, setEditCount] = useState('1');

  const handleAdd = () => {
    const title = newChore.trim();
    const count = parseInt(scheduleCount, 10) || 1;
    if (!title) return;
    addChore(houseId, title, { frequency: scheduleFreq, count });
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
    saveEdit(houseId, editingChore.id, editTitle.trim(), { frequency: editFreq, count });
    setEditModalVisible(false);
    setEditingChore(null);
  };

  const handleDelete = id => deleteChore(houseId, id);

  if (loading) {
    return (
      <SafeAreaView style={[CommonStyles.safe, CommonStyles.centerContent, { paddingTop: insets.top }]}>        
        <Text style={CommonStyles.loadingText}>Loading chores...</Text>
      </SafeAreaView>
    );
  }

  return (
    <>
      <FlatList
        data={chores}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <ChoreItem chore={item} onEdit={handleOpenEdit} onDelete={handleDelete} />
        )}
        style={CommonStyles.listContainer}
      />

      <View style={[CommonStyles.inputContainer, { marginBottom: insets.bottom || 16 }]}>        
        <TextInput
          style={[CommonStyles.input, CommonStyles.inputOverride]}
          placeholder="New chore"
          placeholderTextColor="#888"
          value={newChore}
          onChangeText={setNewChore}
        />

        <FrequencyPickerModal value={scheduleFreq} onChange={setScheduleFreq}>
          <View style={[CommonStyles.input, CommonStyles.pickerToggle]}>
            <Text style={CommonStyles.pickerToggleText}>{scheduleFreq}</Text>
          </View>
        </FrequencyPickerModal>

        <TextInput
          style={[CommonStyles.input, CommonStyles.countInput]}
          placeholder="Count"
          keyboardType="numeric"
          placeholderTextColor="#888"
          value={scheduleCount}
          onChangeText={setScheduleCount}
        />

        <TouchableOpacity style={CommonStyles.centerContent} onPress={handleAdd}>
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
    </>
  );
};

const ChoresScreen = () => {
  const insets = useSafeAreaInsets();
  const houses = useHouses();
  const houseId = houses.length > 0 ? houses[0].id : null;

  if (!houseId) {
    return (
      <SafeAreaView style={[CommonStyles.safe, CommonStyles.centerContent, { paddingTop: insets.top }]}>        
        <Text style={CommonStyles.loadingText}>No houses available. Join or create one.</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={[CommonStyles.safe, { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }]}>
      <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={CommonStyles.flex}>
        <ChoresList key={houseId} houseId={houseId} />
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

export default ChoresScreen;
