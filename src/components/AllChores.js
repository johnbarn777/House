// src/components/AllChores.js
import React from 'react';
import { View, Text, FlatList, Dimensions } from 'react-native';
import ChoreItem from './ChoreItem';
import CommonStyles from '../styles/CommonStyles';

const { height: windowHeight } = Dimensions.get('window');
const maxCardHeight = windowHeight * 0.66; // two thirds

/**
 * Base card for rendering chore lists.
 */
function ChoreCard({ title, chores, onEdit, onDelete }) {
  return (
    <View style={[CommonStyles.card, { maxHeight: maxCardHeight }]}>  
      <Text style={CommonStyles.cardTitle}>{title}</Text>
      <FlatList
        data={chores}
        keyExtractor={item => item.id}
        nestedScrollEnabled
        style={{ flexGrow: 0 }}
        contentContainerStyle={[
          chores.length === 0 && CommonStyles.emptyContainer,
          { paddingVertical: chores.length > 0 ? 8 : 0 }
        ]}
        renderItem={({ item }) => (
          <ChoreItem
            chore={item}
            onEdit={() => onEdit(item)}
            onDelete={() => onDelete(item.id)}
          />
        )}
        ListEmptyComponent={
          <View style={CommonStyles.emptyContainer}>
            <Text style={CommonStyles.emptyText}>No chores yet.</Text>
          </View>
        }
      />
    </View>
  );
}

/**
 * Shows all chores in the house.
 */
export function AllChores({ chores, onEdit, onDelete }) {
  return <ChoreCard title="All Chores" chores={chores} onEdit={onEdit} onDelete={onDelete} />;
}

/**
 * Shows only chores assigned to the current user.
 */
export function MyChores({ chores, currentUserId, onEdit, onDelete }) {
  const myList = chores.filter(c => c.assignedTo === currentUserId);
  return <ChoreCard title="My Chores" chores={myList} onEdit={onEdit} onDelete={onDelete} />;
}

/**
 * Shows chores assigned to other users.
 */
export function OtherChores({ chores, currentUserId, onEdit, onDelete }) {
  const others = chores.filter(c => c.assignedTo && c.assignedTo !== currentUserId);
  return <ChoreCard title="Other Chores" chores={others} onEdit={onEdit} onDelete={onDelete} />;
}
