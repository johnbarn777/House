// src/contexts/HousesContext.tsx
import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from 'react';
import firestore from '@react-native-firebase/firestore';
import { useAuth } from '../hooks/useAuth';

export interface House {
  id: string;
  houseName: string;
  members: string[];
  // …other fields
}

interface HousesContextValue {
  houses: House[];
  currentHouseId: string | null;
  setCurrentHouseId: (id: string) => void;
}

const HousesContext = createContext<HousesContextValue>({
  houses: [],
  currentHouseId: null,
  setCurrentHouseId: () => {},
});

export const HousesProvider: React.FC<{ children: ReactNode }> = ({
  children,
}) => {
  const { user } = useAuth();
  const [houses, setHouses] = useState<House[]>([]);
  const [currentHouseId, setCurrentHouseId] = useState<string | null>(null);

  useEffect(() => {
    if (!user?.uid) return;                         // wait for auth
    const unsubscribe = firestore()
      .collection('houses')
      .where('members', 'array-contains', user.uid) // ← pass the uid here!
      .onSnapshot((snap) => {
        const list = snap.docs.map((doc) => ({
          id: doc.id,
          ...(doc.data() as Omit<House, 'id'>),
        }));
        setHouses(list);
        if (!currentHouseId && list.length > 0) {
          setCurrentHouseId(list[0].id);
        }
      }, console.warn);

    return unsubscribe;
  }, [user?.uid]);

  return (
    <HousesContext.Provider
      value={{ houses, currentHouseId, setCurrentHouseId }}
    >
      {children}
    </HousesContext.Provider>
  );
};

export const useHouses = () => useContext(HousesContext);
