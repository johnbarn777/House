// src/screens/ChoresScreen.js
import React from 'react';
import {
  SafeAreaView,
  Platform,
  KeyboardAvoidingView
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { useHouses } from '../src/contexts/HousesContext';
import ChoresList from '../src/components/ChoresList';
import CommonStyles from '../src/styles/CommonStyles';

const TAB_BAR_HEIGHT = 80;

/**
 * Screen wrapper for chores. Renders ChoresList and handles safe area.
 */
const ChoresScreen = () => {
  const insets = useSafeAreaInsets();
  const { currentHouseId } = useHouses();
  const houseId = currentHouseId;

  if (!houseId) {
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
        <ChoresList houseId={houseId} />
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

export default ChoresScreen;
