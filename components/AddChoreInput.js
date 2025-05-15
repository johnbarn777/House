import React, { useState } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  StyleSheet
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import FrequencyPickerModal from './FrequencyPickerModal';

export default function AddChoreInput({ onAdd }) {
  const [title, setTitle] = useState('');
  const [freq, setFreq] = useState('Daily');
  const [count, setCount] = useState('1');
  const [pickerVisible, setPickerVisible] = useState(false);

  const handleAdd = () => {
    onAdd(title, freq, parseInt(count, 10) || 1);
    setTitle('');
    setCount('1');
  };

  return (
    <View style={styles.row}>
      <TextInput
        style={styles.input}
        placeholder="New chore"
        placeholderTextColor="#888"
        value={title}
        onChangeText={setTitle}
      />
      <TouchableOpacity
        style={[styles.input, styles.pickerToggle]}
        onPress={() => setPickerVisible(true)}
      >
        <Ionicons name="calendar-outline" size={20} />
        <View>
          <Ionicons name="chevron-down-outline" size={16} />
        </View>
        <Text style={styles.pickerText}>{freq}</Text>
      </TouchableOpacity>
      <TextInput
        style={[styles.input, styles.countInput]}
        placeholder="Count"
        keyboardType="numeric"
        placeholderTextColor="#888"
        value={count}
        onChangeText={setCount}
      />
      <TouchableOpacity style={styles.addButton} onPress={handleAdd}>
        <Ionicons name="add-circle" size={36} color="#ae00ff" />
      </TouchableOpacity>

      <FrequencyPickerModal
        visible={pickerVisible}
        value={freq}
        onValueChange={setFreq}
        onClose={() => setPickerVisible(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', padding: 8 },
  input: {
    flex: 1,
    padding: 8,
    marginHorizontal: 4,
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 4
  },
  pickerToggle: { flexDirection: 'row', justifyContent: 'space-between' },
  pickerText: { marginLeft: 4 },
  countInput: { width: 60, textAlign: 'center' },
  addButton: { marginLeft: 8 }
});
