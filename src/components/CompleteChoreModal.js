// src/components/CompleteChoreModal.js
import React, { useState } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  StyleSheet,
  ScrollView
} from 'react-native';
import { launchImageLibrary } from 'react-native-image-picker';
import CommonStyles from '../styles/CommonStyles';
import MaterialIcon from 'react-native-vector-icons/MaterialIcons';

export default function CompleteChoreModal({
  visible,
  onClose,
  onComplete,
  onSnooze,
  choreTitle
}) {
  const [note, setNote] = useState('');
  const [imageUri, setImageUri] = useState(null);

  const pickImage = () => {
    launchImageLibrary({ mediaType: 'photo' }, response => {
      if (response.didCancel) return;
      if (response.errorCode) {
        console.error('ImagePicker Error: ', response.errorMessage);
        return;
      }
      if (response.assets && response.assets.length > 0) {
        setImageUri(response.assets[0].uri);
      }
    });
  };

  const handleComplete = () => {
    onComplete({ note, imageUri });
    setNote('');
    setImageUri(null);
  };

  const handleSnooze = () => {
    onSnooze();
    setNote('');
    setImageUri(null);
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <View style={CommonStyles.overlay}>
        <View style={[CommonStyles.card, CommonStyles.CompleteChoreModalCard]}>
          <Text style={CommonStyles.cardTitle}>
            Complete "{choreTitle}"
          </Text>
          <ScrollView contentContainerStyle={CommonStyles.content}>
            <TextInput
              style={[CommonStyles.input, CommonStyles.noteInput]}
              placeholder="Add a note (optional)"
              placeholderTextColor="#888"
              value={note}
              onChangeText={setNote}
              multiline
            />

            <TouchableOpacity
              style={CommonStyles.imageButton}
              onPress={pickImage}
            >
              <MaterialIcon name="image" size={24} color="#fff" />
              <Text style={[CommonStyles.buttonText, CommonStyles.imageButtonText]}>
                {imageUri ? 'Change Photo' : 'Add Photo'}
              </Text>
            </TouchableOpacity>

            {imageUri && (
              <Image
                source={{ uri: imageUri }}
                style={CommonStyles.imagePreview}
              />
            )}

            <View style={CommonStyles.buttonGroup}>
              <TouchableOpacity
                style={[
                  CommonStyles.primaryButton,
                  !(note || imageUri) && CommonStyles.disabledButton
                ]}
                onPress={handleComplete}
                disabled={!(note || imageUri)}
              >
                <Text style={CommonStyles.buttonText}>Complete</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  CommonStyles.primaryButton,
                  CommonStyles.snoozeButton
                ]}
                onPress={handleSnooze}
              >
                <Text style={CommonStyles.buttonText}>
                  Snooze 1 Day
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  CommonStyles.primaryButton,
                  CommonStyles.closeButton
                ]}
                onPress={onClose}
              >
                <Text style={CommonStyles.buttonText}>Cancel</Text>
              </TouchableOpacity>
            </View>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

