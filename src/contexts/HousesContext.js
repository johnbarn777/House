import React, { createContext, useContext, useEffect, useState } from 'react';
import firestore from '@react-native-firebase/firestore';
import { useAuth } from '../hooks/useAuth';

const HousesContext = createContext([]);

export const HousesProvider = ({ children }) => {
  const { user, initializing } = useAuth();
  const [houses, setHouses] = useState([]);

  useEffect(() => {
    if (initializing || !user) return;

    const uid = user.uid;
    const unsubscribe = firestore()
      .collection('houses')
      .where('members', 'array-contains', uid)
      .onSnapshot(
        snapshot => {
          setHouses(
            snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))
          );
        },
        err => {
          console.error('house subscription error', err);
        }
      );

    return () => unsubscribe();
  }, [initializing, user]);

  return (
    <HousesContext.Provider value={houses}>
      {children}
    </HousesContext.Provider>
  );
};

export const useHouses = () => useContext(HousesContext);
