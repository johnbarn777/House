// src/contexts/UsersContext.js
import React, { createContext, useContext, useEffect, useState, useRef } from 'react';
import firestore, { firebase } from '@react-native-firebase/firestore';

const UsersContext = createContext({});

export const UsersProvider = ({ houseId, children }) => {
  const [usersMap, setUsersMap] = useState({});
  const batchUnsubs = useRef([]);

  useEffect(() => {
    if (!houseId) return;
    // 1) Listen to the House doc to get its `members` array
    const houseUnsub = firestore()
      .collection('houses')
      .doc(houseId)
      .onSnapshot(houseSnap => {
        if (!houseSnap.exists) return;
        const members = houseSnap.data().members || [];

        // clear out old user listeners & map
        batchUnsubs.current.forEach(unsub => unsub());
        batchUnsubs.current = [];
        setUsersMap({});

        // Firestore `in` only supports ≤10 IDs per query, so chunk:
        for (let i = 0; i < members.length; i += 10) {
          const chunk = members.slice(i, i + 10);

          const unsub = firestore()
            .collection('users')
            .where(firebase.firestore.FieldPath.documentId(), 'in', chunk)
            .onSnapshot(qsnap => {
              setUsersMap(prev => {
                const next = { ...prev };
                qsnap.forEach(doc => {
                  const { name, photoURL } = doc.data();
                  next[doc.id] = { name, photoURL };
                });
                return next;
              });
            }, console.warn);

          batchUnsubs.current.push(unsub);
        }
      }, console.warn);

    return () => {
      houseUnsub();
      batchUnsubs.current.forEach(unsub => unsub());
    };
  }, [houseId]);

  return (
    <UsersContext.Provider value={usersMap}>
      {children}
    </UsersContext.Provider>
  );
};

export const useUsers = () => useContext(UsersContext);
