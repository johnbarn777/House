import { useState, useEffect } from 'react';
import { Alert } from 'react-native';
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

export default function useChores() {
  const auth = getAuth(getApp());
  const user = auth.currentUser;
  const db = getFirestore(getApp());

  const [chores, setChores] = useState([]);
  const [houseId, setHouseId] = useState(null);
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let unsubscribe;
    const init = async () => {
      try {
        const housesQ = query(
            collection(db, 'houses'),
            where('members', 'array-contains', user.uid)
        );
        const snap = await getDocs(housesQ);
        if (!snap.empty) {
          const houseDoc = snap.docs[0];
          const id = houseDoc.id;
          setHouseId(id);
          setMembers(houseDoc.data().members || []);

          const choresQ = query(
              collection(db, 'houses', id, 'chores'),
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
        } else {
          setLoading(false);
        }
      } catch (error) {
        console.error(error);
        Alert.alert('Error', 'Could not load chores.');
        setLoading(false);
      }
    };
    init();
    return () => unsubscribe && unsubscribe();
  }, [user.uid]);

  const addChore = async (title, schedule) => {
    const count = schedule.count || 1;
    if (!title.trim() || !houseId) return;
    try {
      await addDoc(
          collection(db, 'houses', houseId, 'chores'),
          {
            title: title.trim(),
            createdAt: serverTimestamp(),
            createdBy: user.uid,
            assignedTo: null,
            schedule: { frequency: schedule.frequency, count }
          }
      );
    } catch (error) {
      console.error(error);
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
      console.error(error);
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
      console.error(error);
      Alert.alert('Error', 'Could not unassign chores.');
    }
  };

  const saveEdit = async (choreId, title, schedule) => {
    const count = schedule.count || 1;
    if (!choreId) return;
    try {
      await updateDoc(
          docRef(db, 'houses', houseId, 'chores', choreId),
          {
            title: title.trim(),
            'schedule.frequency': schedule.frequency,
            'schedule.count': count
          }
      );
    } catch (error) {
      console.error(error);
      Alert.alert('Error', 'Could not save changes.');
    }
  };

  const deleteChore = async choreId => {
    try {
      await deleteDoc(docRef(db, 'houses', houseId, 'chores', choreId));
    } catch (error) {
      console.error(error);
      Alert.alert('Error', 'Could not delete chore.');
    }
  };

  return {
    chores,
    loading,
    houseId,
    members,
    addChore,
    autoAssign,
    unassignAll,
    saveEdit,
    deleteChore
  };
}
