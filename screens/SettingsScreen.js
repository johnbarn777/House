// SettingsScreen.js
import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  ActivityIndicator,
  StyleSheet,
  Dimensions,
} from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import { getAuth, signOut } from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';

// Custom hook for auth state
import { useAuth } from '../src/hooks/useAuth';

// Refactored components
import ProfileCard from '../src/components/ProfileCard';
import HousesCard from '../src/components/HousesCard';

const { width } = Dimensions.get('window');

const SettingsScreen = ({ navigation }) => {
  const { user, initializing } = useAuth();
  const auth = getAuth();
  const [houses, setHouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Always register effect hooks unconditionally
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

  // Sign out action
  const handleSignOut = async () => {
    try {
      await signOut(auth);
    } catch {
      setError('Sign-out failed');
    }
  };

  // Conditional rendering based on auth and data state
  if (initializing) {
    return (
      <SafeAreaView style={styles.centered}>
        <ActivityIndicator size="large" color="#ae00ff" />
      </SafeAreaView>
    );
  }

  if (!user) {
    // Auth flow should take over via context/navigator
    return null;
  }

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
        <ProfileCard
          user={user}
          onSignOut={handleSignOut}
          error={error}
        />
        <HousesCard
          userId={user.uid}
          houses={houses}
          navigation={navigation}
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
