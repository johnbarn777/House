// src/screens/ChoresScreen.js
import React from 'react';
import {
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  Text,
  View
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRoute } from '@react-navigation/native';

import { useHouses } from '../src/contexts/HousesContext';
import ChoresList from '../src/components/ChoresList';
import CommonStyles from '../src/styles/CommonStyles';

const TAB_BAR_HEIGHT = 80;

const ChoresScreen = () => {
  const insets = useSafeAreaInsets();
  const { currentHouseId } = useHouses();
  const route = useRoute();

  // grab the param we passed in App.tsx
  const openCompleteId = route.params?.openComplete;

  if (!currentHouseId) {
    return (
      <SafeAreaView
        style={[
          CommonStyles.safe,
          CommonStyles.centerContent,
          { paddingTop: insets.top }
        ]}
      >
        <Text style={CommonStyles.loadingText}>
          No house selected. Please pick a house.
        </Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView
      style={[
        CommonStyles.safe,
        { paddingBottom: insets.bottom + TAB_BAR_HEIGHT }
      ]}
    >
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={CommonStyles.flex}
      >
        <ChoresList
          key={currentHouseId}
          houseId={currentHouseId}
          openCompleteId={openCompleteId}
        />
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

export default ChoresScreen;
