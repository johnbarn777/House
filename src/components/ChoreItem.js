// src/components/ChoreItem.js
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Swipeable } from 'react-native-gesture-handler';
import { useUsers } from '../contexts/UsersContext';

const ChoreItem = ({ chore, onEdit, onDelete }) => {
  const users = useUsers();

  // Normalize assignedTo to a UID string
  const assignedUid =
    typeof chore.assignedTo === 'string'
      ? chore.assignedTo
      : chore.assignedTo?.id;

  // Lookup display name
  const assignedName = assignedUid
    ? users[assignedUid]?.name
    : null;

  const renderRightActions = () => (
    <View style={styles.actionsContainer}>
      <TouchableOpacity
        style={[styles.actionButton, styles.editButton]}
        onPress={() => onEdit(chore)}
      >
        <Text style={styles.actionText}>Edit</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={[styles.actionButton, styles.deleteButton]}
        onPress={() => onDelete(chore.id)}
      >
        <Text style={styles.actionText}>Delete</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <Swipeable renderRightActions={renderRightActions}>
      <View style={styles.choreItem}>
        <Text style={styles.choreText}>{chore.title}</Text>
        <Text style={styles.assignedText}>
          {assignedName
            ? `Assigned to: ${assignedName}`
            : 'Unassigned'}
        </Text>
        <Text style={styles.scheduleText}>
          {`${chore.schedule.frequency} x ${chore.schedule.count}`}
        </Text>
      </View>
    </Swipeable>
  );
};

const styles = StyleSheet.create({
  actionsContainer: { flexDirection: 'row', width: 160 },
  actionButton: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  editButton: { backgroundColor: '#aaa' },
  deleteButton: { backgroundColor: '#ff5252' },
  actionText: { color: '#fff', fontWeight: 'bold' },
  choreItem: {
    backgroundColor: '#1E1E1E',
    padding: 12,
    borderRadius: 8,
    marginBottom: 12
  },
  choreText: { color: '#fff', fontSize: 16 },
  assignedText: { color: '#bbb', fontSize: 14, marginTop: 4 },
  scheduleText: { color: '#bbb', fontSize: 14, marginTop: 2 },
});

export default ChoreItem;
