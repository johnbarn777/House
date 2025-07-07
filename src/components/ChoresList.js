// src/components/ChoresList.js
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  SectionList,
  StyleSheet
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import MaterialIcon from 'react-native-vector-icons/MaterialIcons';
import auth from '@react-native-firebase/auth';

import useChores from '../hooks/useChores';
import { AllChores, MyChores, OtherChores } from './AllChores';
import FrequencyPickerModal from './FrequencyPickerModal';
import EditChoreModal from './EditChoreModal';
import CommonStyles from '../styles/CommonStyles';

const INPUT_BAR_HEIGHT = 100;  // adjust to match your inputContainer height

const ChoresList = ({ houseId }) => {
  const insets = useSafeAreaInsets();
  const {
    chores,
    loading,
    addChore,
    autoAssign,
    unassignAll,
    saveEdit,
    deleteChore
  } = useChores(houseId);

  const currentUserId = auth().currentUser.uid;

  // Input state
  const [newChore, setNewChore] = useState('');
  const [scheduleFreq, setScheduleFreq] = useState('Daily');
  const [scheduleCount, setScheduleCount] = useState('1');

  // Edit modal state
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingChore, setEditingChore] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editFreq, setEditFreq] = useState('Daily');
  const [editCount, setEditCount] = useState('1');

  if (loading) {
    return (
      <View
        style={[
          CommonStyles.centerContent,
          CommonStyles.safe,
          { paddingTop: insets.top }
        ]}
      >
        <Text style={CommonStyles.loadingText}>Loading chores...</Text>
      </View>
    );
  }

  // Handlers
  const handleAdd = () => {
    const title = newChore.trim();
    const count = parseInt(scheduleCount, 10) || 1;
    if (!title) return;
    addChore(title, { frequency: scheduleFreq, count });
    setNewChore('');
    setScheduleCount('1');
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
    saveEdit(editingChore.id, editTitle.trim(), {
      frequency: editFreq,
      count
    });
    setEditModalVisible(false);
    setEditingChore(null);
  };

  const handleDelete = id => deleteChore(id);

  const sections = [
    { key: 'buttons', data: [{}] },
    { key: 'all',     data: [{}] },
    { key: 'my',      data: [{}] },
    { key: 'other',   data: [{}] }
  ];

  return (
    <View style={styles.container}>
      <SectionList
        sections={sections}
        keyExtractor={(item, index) => `${item.key || 'section'}-${index}`}
        renderItem={({ section }) => {
          switch (section.key) {
            case 'buttons':
              return (
                <View style={CommonStyles.buttonRow}>
                  <TouchableOpacity
                    style={CommonStyles.autoButton}
                    onPress={autoAssign}
                  >
                    <Text style={CommonStyles.autoButtonText}>
                      Auto-Assign
                    </Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={CommonStyles.unassignButton}
                    onPress={unassignAll}
                  >
                    <Text style={CommonStyles.unassignButtonText}>
                      Unassign All
                    </Text>
                  </TouchableOpacity>
                </View>
              );
            case 'all':
              return (
                <View style={{ marginBottom: 16 }}>
                  <AllChores
                    chores={chores}
                    onEdit={handleOpenEdit}
                    onDelete={handleDelete}
                  />
                </View>
              );
            case 'my':
              return (
                <View style={{ marginBottom: 16 }}>
                  <MyChores
                    chores={chores}
                    currentUserId={currentUserId}
                    onEdit={handleOpenEdit}
                    onDelete={handleDelete}
                  />
                </View>
              );
            case 'other':
              return (
                <View style={{ marginBottom: 16 }}>
                  <OtherChores
                    chores={chores}
                    currentUserId={currentUserId}
                    onEdit={handleOpenEdit}
                    onDelete={handleDelete}
                  />
                </View>
              );
            default:
              return null;
          }
        }}
        contentContainerStyle={{
          padding: 16,
          paddingBottom: INPUT_BAR_HEIGHT
        }}
        stickySectionHeadersEnabled={false}
        nestedScrollEnabled
        showsVerticalScrollIndicator={false}
        style={{ flex: 1 }}
      />

      {/* Locked Input Row */}
      <View
        style={[
          CommonStyles.inputContainer,
          {
            position: 'absolute',
            left: 0,
            right: 0,
            bottom: insets.bottom
          }
        ]}
      >
        <TextInput
          style={[CommonStyles.input, CommonStyles.inputOverride]}
          placeholder="New chore"
          placeholderTextColor="#888"
          value={newChore}
          onChangeText={setNewChore}
        />
        <FrequencyPickerModal
          value={scheduleFreq}
          onChange={setScheduleFreq}
        >
          <View style={[CommonStyles.input, CommonStyles.pickerToggle]}>
            <Text style={CommonStyles.pickerToggleText}>
              {scheduleFreq}
            </Text>
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
        <TouchableOpacity
          style={CommonStyles.centerContent}
          onPress={handleAdd}
        >
          <MaterialIcon name="add-circle" size={36} color="#ae00ff" />
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
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1
  }
});

export default ChoresList;
