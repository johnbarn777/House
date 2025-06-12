// SettingsScreen.js
import React, { useState, useEffect } from 'react';
import { SafeAreaView, ActivityIndicator, StyleSheet, Dimensions } from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import { getAuth, signOut } from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import { getApp } from '@react-native-firebase/app';

// We’ve refactored the two major sections into separate components:
import ProfileCard from '../src/components/ProfileCard';
import HousesCard from '../src/components/HousesCard';

const { width } = Dimensions.get('window');

const SettingsScreen = () => {
  const auth = getAuth(getApp());
  const user = auth.currentUser;
  const uid = user.uid;
  const [houses, setHouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Listen for houses the user belongs to
  useEffect(() => {
    const unsubscribe = firestore()
      .collection('houses')
      .where('members', 'array-contains', uid)
      .onSnapshot(
        snapshot => {
          setHouses(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
          setLoading(false);
        },
        e => {
          setError('Could not load houses.');
          setLoading(false);
        }
      );
    return () => unsubscribe();
  }, [uid]);

  const handleSignOut = async () => {
    try {
      await signOut(auth);
    } catch (e) {
      setError('Sign-out failed');
    }
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.centered}>
        <ActivityIndicator size="large" color="#ae00ff" />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe}>
      <KeyboardAwareScrollView
        contentContainerStyle={styles.scrollContent}
        enableOnAndroid
        keyboardShouldPersistTaps="handled"
        extraScrollHeight={20}
      >
        {/* ProfileCard handles photo, name, phone, email/password changes, sign-out */}
        <ProfileCard
          user={user}
          onSignOut={handleSignOut}
        />

        {/* HousesCard handles listing & leaving houses */}
        <HousesCard
          userId={uid}
          houses={houses}
        />
      </KeyboardAwareScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#000' },
  scrollContent: { flexGrow: 1, justifyContent: 'center', padding: 20 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#000' },
});

export default SettingsScreen;
