// src/components/ChoresList.js
import React, { useState, useEffect } from 'react';
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
import {
  AllChores,
  MyChores,
  OtherChores
} from './AllChores';
import FrequencyPickerModal from './FrequencyPickerModal';
import EditChoreModal from './EditChoreModal';
import CompleteChoreModal from './CompleteChoreModal';
import CommonStyles from '../styles/CommonStyles';

const INPUT_BAR_HEIGHT = 100;

const ChoresList = ({
  houseId,
  openCompleteId  // new prop
}) => {
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

  // Input
  const [newChore, setNewChore] = useState('');
  const [scheduleFreq, setScheduleFreq] = useState('Daily');
  const [scheduleCount, setScheduleCount] = useState('1');

  // Edit modal
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingChore, setEditingChore] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editFreq, setEditFreq] = useState('Daily');
  const [editCount, setEditCount] = useState('1');

  // Complete modal
  const [completeModalVisible, setCompleteModalVisible] = useState(false);
  const [selectedChore, setSelectedChore] = useState(null);

  // open complete if route param arrives
  useEffect(() => {
    if (openCompleteId && chores.length > 0) {
      const chore = chores.find(c => c.id === openCompleteId);
      if (chore) {
        setSelectedChore(chore);
        setCompleteModalVisible(true);
      }
    }
  }, [openCompleteId, chores]);

  if (loading) {
    return (
      <View
        style={[
          CommonStyles.centerContent,
          CommonStyles.safe,
          { paddingTop: insets.top }
        ]}
      >
        <Text style={CommonStyles.loadingText}>
          Loading chores...
        </Text>
      </View>
    );
  }

  // Handlers…
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

  const handleOpenComplete = chore => {
    setSelectedChore(chore);
    setCompleteModalVisible(true);
  };

  const handleCloseComplete = () => {
    setCompleteModalVisible(false);
    setSelectedChore(null);
  };

  const handleComplete = ({ note, imageUri }) => {
    // TODO: mark done in Firestore...
    handleCloseComplete();
  };

  const handleSnooze = () => {
    // TODO: snooze in Firestore...
    handleCloseComplete();
  };

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
        keyExtractor={(item, idx) => `${item.key || 'section'}-${idx}`}
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
                    onPress={handleOpenComplete}
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
                    onPress={handleOpenComplete}
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
                    onPress={handleOpenComplete}
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

      {/* Input Row */}
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
        {/* …same as before… */}
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

      <CompleteChoreModal
        visible={completeModalVisible}
        onClose={handleCloseComplete}
        choreTitle={selectedChore?.title}
        onComplete={handleComplete}
        onSnooze={handleSnooze}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1 }
});

export default ChoresList;
