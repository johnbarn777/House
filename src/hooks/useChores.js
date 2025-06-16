// src/hooks/useChores.js
import { useState, useEffect } from 'react';
import { Alert } from 'react-native';
import {
  getFirestore,
  collection,
  onSnapshot,
  addDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  doc as docRef,
  orderBy,
  query as firestoreQuery
} from '@react-native-firebase/firestore';
import { getAuth } from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import { useHouses } from '../contexts/HousesContext';

export default function useChores() {
  const auth = getAuth(getApp());
  const user = auth.currentUser;
  const db = getFirestore(getApp());

  // Get the active houseId and members from context
  const { currentHouseId, houses } = useHouses();
  const houseId = currentHouseId;
  const members = houses.find(h => h.id === houseId)?.members || [];

  const [chores, setChores] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!houseId) {
      setChores([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    const choresRef = collection(db, 'houses', houseId, 'chores');
    const choresQuery = firestoreQuery(choresRef, orderBy('createdAt', 'desc'));

    const unsubscribe = onSnapshot(
      choresQuery,
      snapshot => {
        const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
        setChores(list);
        setLoading(false);
      },
      error => {
        console.error('Chores subscription error:', error);
        Alert.alert('Error', 'Could not subscribe to chores.');
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, [db, houseId]);

  const addChore = async (title, schedule) => {
    if (!houseId || !title.trim()) return;
    try {
      await addDoc(
        collection(db, 'houses', houseId, 'chores'),
        {
          title: title.trim(),
          createdAt: serverTimestamp(),
          createdBy: user.uid,
          assignedTo: null,
          schedule: { frequency: schedule.frequency, count: schedule.count || 1 }
        }
      );
    } catch (error) {
      console.error('Add chore error:', error);
      Alert.alert('Error', 'Could not add chore.');
    }
  };

  const autoAssign = async () => {
    if (!houseId || members.length === 0) return;
    const unassigned = chores.filter(c => !c.assignedTo);
    try {
      await Promise.all(
        unassigned.map(c =>
          updateDoc(
            docRef(db, 'houses', houseId, 'chores', c.id),
            { assignedTo: members[Math.floor(Math.random() * members.length)] }
          )
        )
      );
    } catch (error) {
      console.error('Auto-assign error:', error);
      Alert.alert('Error', 'Could not auto-assign chores.');
    }
  };

  const unassignAll = async () => {
    if (!houseId) return;
    const assigned = chores.filter(c => c.assignedTo);
    try {
      await Promise.all(
        assigned.map(c =>
          updateDoc(
            docRef(db, 'houses', houseId, 'chores', c.id),
            { assignedTo: null }
          )
        )
      );
    } catch (error) {
      console.error('Unassign all error:', error);
      Alert.alert('Error', 'Could not unassign chores.');
    }
  };

  const saveEdit = async (choreId, title, schedule) => {
    if (!houseId || !choreId) return;
    try {
      await updateDoc(
        docRef(db, 'houses', houseId, 'chores', choreId),
        {
          title: title.trim(),
          'schedule.frequency': schedule.frequency,
          'schedule.count': schedule.count || 1
        }
      );
    } catch (error) {
      console.error('Save edit error:', error);
      Alert.alert('Error', 'Could not save chore.');
    }
  };

  const deleteChore = async choreId => {
    if (!houseId || !choreId) return;
    try {
      await deleteDoc(docRef(db, 'houses', houseId, 'chores', choreId));
    } catch (error) {
      console.error('Delete chore error:', error);
      Alert.alert('Error', 'Could not delete chore.');
    }
  };

  return {
    chores,
    loading,
    addChore,
    autoAssign,
    unassignAll,
    saveEdit,
    deleteChore
  };
}
