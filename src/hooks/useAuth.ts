// hooks/useAuth.ts
import { useState, useEffect } from 'react';
import messaging from '@react-native-firebase/messaging';
import {
  getAuth,
  onAuthStateChanged,
  FirebaseAuthTypes
} from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import {
  getFirestore,
  doc as docRef,
  setDoc,
  serverTimestamp
} from '@react-native-firebase/firestore';

export function useAuth() {
  const [initializing, setInitializing] = useState(true);
  const [user, setUser] = useState<FirebaseAuthTypes.User | null>(null);

  const auth = getAuth(getApp());
  const db = getFirestore(getApp());

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
      setUser(u);

      if (u) {
        try {
          // 1. Ask for permission
          const authStatus = await messaging().requestPermission();
          const enabled =
            authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
            authStatus === messaging.AuthorizationStatus.PROVISIONAL;

          if (enabled) {
            // 2. Get & save the token
            const token = await messaging().getToken();
            await setDoc(
              docRef(db, 'users', u.uid, 'deviceTokens', token),
              { createdAt: serverTimestamp() }
            );

            // 3. Keep in sync on refresh
            messaging().onTokenRefresh(async (newToken) => {
              try {
                await setDoc(
                  docRef(db, 'users', u.uid, 'deviceTokens', newToken),
                  { createdAt: serverTimestamp() }
                );
              } catch (e) {
                console.error('FCM token refresh failed', e);
              }
            });
          }
        } catch (e) {
          console.error('FCM registration failed', e);
        }
      }

      if (initializing) {
        setInitializing(false);
      }
    });

    return unsubscribe;
  }, [auth, db, initializing]);

  return { user, initializing };
}