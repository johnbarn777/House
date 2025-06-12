// src/components/FrequencyPickerModal.js
import React, { useState } from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  FlatList,
  StyleSheet
} from 'react-native';

const OPTIONS = ['Daily', 'Weekly', 'Bi-weekly', 'Monthly'];

export default function FrequencyPickerModal({ value, onChange, children }) {
  const [visible, setVisible] = useState(false);

  const open = () => setVisible(true);
  const close = () => setVisible(false);

  const handleSelect = (option) => {
    onChange(option);
    close();
  };

  return (
    <>
      {/* Toggle */}
      <TouchableOpacity onPress={open} activeOpacity={0.7}>
        {children}
      </TouchableOpacity>

      {/* Overlay Modal */}
      <Modal
        visible={visible}
        transparent
        animationType="fade"
        onRequestClose={close}
      >
        <TouchableWithoutFeedback onPress={close}>
          <View style={styles.overlay}>
            <TouchableWithoutFeedback>
              <View style={styles.modal}>
                <FlatList
                  data={OPTIONS}
                  keyExtractor={(item) => item}
                  renderItem={({ item }) => (
                    <TouchableOpacity
                      style={styles.option}
                      onPress={() => handleSelect(item)}
                    >
                      <Text style={[
                        styles.optionText,
                        item === value && styles.selectedText
                      ]}>
                        {item}
                      </Text>
                    </TouchableOpacity>
                  )}
                />
              </View>
            </TouchableWithoutFeedback>
          </View>
        </TouchableWithoutFeedback>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    paddingHorizontal: 40
  },
  modal: {
    backgroundColor: '#262626',
    borderRadius: 8,
    maxHeight: '50%'
  },
  option: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderBottomColor: '#444',
    borderBottomWidth: 1
  },
  optionText: {
    fontSize: 16,
    color: '#fff'
  },
  selectedText: {
    fontWeight: '700'
  }
});
