// SettingsScreen.js
import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  ActivityIndicator,
  Dimensions
} from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import { getAuth, signOut } from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import { useAuth } from '../src/hooks/useAuth';
import ProfileCard from '../src/components/ProfileCard';
import HousesCard from '../src/components/HousesCard';

import CommonStyles from '../src/styles/CommonStyles';

const { width } = Dimensions.get('window');

const SettingsScreen = ({ navigation }) => {
  const { user, initializing } = useAuth();
  const auth = getAuth();
  const [houses, setHouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (initializing || !user) return;
    const uid = user.uid;
    const unsubscribe = firestore()
      .collection('houses')
      .where('members', 'array-contains', uid)
      .onSnapshot(
        snapshot => {
          setHouses(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
          setLoading(false);
        },
        () => {
          setError('Could not load houses.');
          setLoading(false);
        }
      );
    return () => unsubscribe();
  }, [initializing, user]);

  const handleSignOut = async () => {
    try {
      await signOut(auth);
    } catch {
      setError('Sign-out failed');
    }
  };

  if (initializing || loading) {
    return (
      <SafeAreaView style={CommonStyles.container}>
        <ActivityIndicator size="large" color="#ae00ff" />
      </SafeAreaView>
    );
  }

  if (!user) return null;

  return (
    <SafeAreaView style={CommonStyles.safe}>
      <KeyboardAwareScrollView
        contentContainerStyle={CommonStyles.settingsScrollContent}
        enableOnAndroid
        keyboardShouldPersistTaps="handled"
        extraScrollHeight={20}
      >
        <ProfileCard user={user} onSignOut={handleSignOut} error={error} />
        <HousesCard userId={user.uid} houses={houses} navigation={navigation} />
      </KeyboardAwareScrollView>
    </SafeAreaView>
  );
};

export default SettingsScreen;
