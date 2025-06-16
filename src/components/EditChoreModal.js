// src/components/EditChoreModal.js
import React from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  TouchableWithoutFeedback,
  StyleSheet
} from 'react-native';
import FrequencyPickerModal from './FrequencyPickerModal';

export default function EditChoreModal({
                                         visible,
                                         onClose,
                                         title,
                                         onChangeTitle,
                                         freq,
                                         onChangeFreq,
                                         count,
                                         onChangeCount,
                                         onSave
                                       }) {
  return (
      <Modal visible={visible} transparent animationType="slide">
        {/* background tap to close */}
        <TouchableWithoutFeedback onPress={onClose}>
          <View style={styles.overlay}>
            {/* inner content – stops propagation */}
            <TouchableWithoutFeedback>
              <View style={styles.container}>
                <Text style={styles.heading}>Edit Chore</Text>

                <TextInput
                    style={styles.input}
                    placeholder="Chore title"
                    placeholderTextColor="#888"
                    value={title}
                    onChangeText={onChangeTitle}
                />

                {/* frequency picker */}
                <FrequencyPickerModal value={freq} onChange={onChangeFreq}>
                  <View style={styles.pickerToggle}>
                    <Text style={styles.pickerText}>{freq}</Text>
                  </View>
                </FrequencyPickerModal>

                <TextInput
                    style={styles.input}
                    placeholder="Count"
                    placeholderTextColor="#888"
                    keyboardType="numeric"
                    value={count}
                    onChangeText={onChangeCount}
                />

                <TouchableOpacity style={styles.saveBtn} onPress={onSave}>
                  <Text style={styles.saveText}>Save</Text>
                </TouchableOpacity>
              </View>
            </TouchableWithoutFeedback>
          </View>
        </TouchableWithoutFeedback>
      </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center'
  },
  container: {
    width: '80%',
    backgroundColor: '#262626',
    borderRadius: 8,
    padding: 20
  },
  heading: {
    fontSize: 18,
    color: '#fff',
    textAlign: 'center',
    marginBottom: 16
  },
  input: {
    backgroundColor: '#1f1f1f',
    color: '#fff',
    borderRadius: 24,
    paddingHorizontal: 16,
    height: 48,
    marginBottom: 12
  },
  pickerToggle: {
    backgroundColor: '#1f1f1f',
    borderRadius: 24,
    height: 48,
    justifyContent: 'center',
    paddingHorizontal: 16,
    marginBottom: 12
  },
  pickerText: {
    color: '#fff',
    fontSize: 16
  },
  saveBtn: {
    backgroundColor: '#ae00ff',
    borderRadius: 8,
    paddingVertical: 12,
    alignItems: 'center'
  },
  saveText: {
    color: '#fff',
    fontWeight: '600'
  }
});
