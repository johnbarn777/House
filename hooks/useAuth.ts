// hooks/useAuth.ts
import React, { useState, useEffect } from 'react';
import auth from '@react-native-firebase/auth';
import { FirebaseAuthTypes } from '@react-native-firebase/auth';


export function useAuth() {
    const [initializing, setInitializing] = useState(true);
    const [user, setUser] = useState<FirebaseAuthTypes.User|null>(null);
  
    useEffect(() => {
      const unsub = auth().onAuthStateChanged(u => {
        setUser(u);
        setInitializing(false);
      });
      return unsub;
    }, []);
  
    return { user, initializing };
  }
  