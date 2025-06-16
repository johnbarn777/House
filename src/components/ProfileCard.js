// components/ProfileCard.js
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  ActivityIndicator,
  StyleSheet,
  Dimensions,
  Alert,
} from 'react-native';
import firestore from '@react-native-firebase/firestore';
import storage from '@react-native-firebase/storage';
import {
  getAuth,
  reauthenticateWithCredential,
  EmailAuthProvider,
  updateEmail as firebaseUpdateEmail,
  updatePassword as firebaseUpdatePassword,
} from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import { launchImageLibrary } from 'react-native-image-picker';

const { width } = Dimensions.get('window');

const ProfileCard = ({ user, onSignOut }) => {
  const uid = user.uid;

  // Profile fields
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [photoURL, setPhotoURL] = useState(null);
  const [localImageUri, setLocalImageUri] = useState(null);

  // Security forms
  const [showEmailForm, setShowEmailForm] = useState(false);
  const [newEmail, setNewEmail] = useState('');
  const [emailPassword, setEmailPassword] = useState('');
  const [emailLoading, setEmailLoading] = useState(false);

  const [showPasswordForm, setShowPasswordForm] = useState(false);
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmNewPassword, setConfirmNewPassword] = useState('');
  const [passwordLoading, setPasswordLoading] = useState(false);

  // Loading and error
  const [loadingProfile, setLoadingProfile] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const doc = await firestore().collection('users').doc(uid).get();
        const data = doc.data() || {};
        setName(data.name || '');
        setPhone(data.phone || '');
        setPhotoURL(data.photoURL || null);
      } catch (e) {
        setError('Could not load profile');
      } finally {
        setLoadingProfile(false);
      }
    };
    fetchProfile();
  }, [uid]);

  const handleChoosePhoto = async () => {
    try {
      const res = await launchImageLibrary({ mediaType: 'photo', quality: 0.8 });
      if (res.assets?.length) setLocalImageUri(res.assets[0].uri);
    } catch {
      setError('Image picker error');
    }
  };

  const uploadProfilePhoto = async () => {
    if (!localImageUri) return photoURL;
    setUploading(true);
    const resp = await fetch(localImageUri);
    const blob = await resp.blob();
    const ref = storage().ref(`profilePictures/${uid}.jpg`);
    await ref.put(blob);
    const url = await ref.getDownloadURL();
    setUploading(false);
    setPhotoURL(url);
    return url;
  };

  const handleSave = async () => {
    setError('');
    setSaving(true);
    try {
      const finalURL = await uploadProfilePhoto();
      await firestore().collection('users').doc(uid).update({
        name: name.trim(),
        phone: phone.trim() || null,
        photoURL: finalURL || null,
      });
      Alert.alert('Profile saved');
    } catch {
      setError('Save failed');
    } finally {
      setSaving(false);
    }
  };

  const handleUpdateEmail = async () => {
    if (!newEmail || !emailPassword) return setError('Enter both fields');
    setEmailLoading(true);
    try {
      const cred = EmailAuthProvider.credential(user.email, emailPassword);
      await reauthenticateWithCredential(user, cred);
      await firebaseUpdateEmail(user, newEmail.trim());
      Alert.alert('Email updated');
      setShowEmailForm(false);
      setNewEmail(''); setEmailPassword('');
    } catch {
      setError('Email update failed');
    } finally {
      setEmailLoading(false);
    }
  };

  const handleUpdatePassword = async () => {
    if (!currentPassword || !newPassword || newPassword !== confirmNewPassword) 
      return setError('Check passwords');
    setPasswordLoading(true);
    try {
      const cred = EmailAuthProvider.credential(user.email, currentPassword);
      await reauthenticateWithCredential(user, cred);
      await firebaseUpdatePassword(user, newPassword.trim());
      Alert.alert('Password updated');
      setShowPasswordForm(false);
      setCurrentPassword(''); setNewPassword(''); setConfirmNewPassword('');
    } catch {
      setError('Password update failed');
    } finally {
      setPasswordLoading(false);
    }
  };

  if (loadingProfile) {
    return <ActivityIndicator size="large" color="#ae00ff" />;
  }

  return (
    <View style={styles.card}>
      <Text style={styles.title}>Profile</Text>
      {!!error && <Text style={styles.error}>{error}</Text>}

      <TouchableOpacity style={styles.avatarContainer} onPress={handleChoosePhoto}>
        {localImageUri||photoURL ? (
          <Image source={{uri:localImageUri||photoURL}} style={styles.avatar}/>
        ) : (
          <View style={styles.avatarPlaceholder}><Text style={styles.avatarPlaceholderText}>+</Text></View>
        )}
        {uploading && <ActivityIndicator style={StyleSheet.absoluteFill} color="#fff" />}
      </TouchableOpacity>

      <TextInput style={styles.input} placeholder="Full Name" placeholderTextColor="#bbb" value={name} onChangeText={setName} />
      <TextInput style={styles.input} placeholder="Phone (optional)" placeholderTextColor="#bbb" keyboardType="phone-pad" value={phone} onChangeText={setPhone} />

      <TouchableOpacity style={styles.primaryButton} onPress={handleSave} disabled={saving}>
        <Text style={styles.buttonText}>{saving?'Saving...':'Save Changes'}</Text>
      </TouchableOpacity>

      {/* Email Change */}
      <TouchableOpacity style={styles.secondaryButton} onPress={()=>setShowEmailForm(!showEmailForm)}>
        <Text style={styles.secondaryButtonText}>{showEmailForm?'Cancel Email':'Change Email'}</Text>
      </TouchableOpacity>
      {showEmailForm && (
        <>        
          <TextInput style={styles.input} placeholder="New Email" placeholderTextColor="#bbb" keyboardType="email-address" autoCapitalize="none" value={newEmail} onChangeText={setNewEmail}/>
          <TextInput style={styles.input} placeholder="Current Password" placeholderTextColor="#bbb" secureTextEntry value={emailPassword} onChangeText={setEmailPassword}/>
          <TouchableOpacity style={styles.primaryButton} onPress={handleUpdateEmail} disabled={emailLoading}>
            <Text style={styles.buttonText}>{emailLoading?'Updating...':'Update Email'}</Text>
          </TouchableOpacity>
        </>
      )}

      {/* Password Change */}
      <TouchableOpacity style={styles.secondaryButton} onPress={()=>setShowPasswordForm(!showPasswordForm)}>
        <Text style={styles.secondaryButtonText}>{showPasswordForm?'Cancel Password':'Change Password'}</Text>
      </TouchableOpacity>
      {showPasswordForm && (
        <>        
          <TextInput style={styles.input} placeholder="Current Password" placeholderTextColor="#bbb" secureTextEntry value={currentPassword} onChangeText={setCurrentPassword}/>
          <TextInput style={styles.input} placeholder="New Password" placeholderTextColor="#bbb" secureTextEntry value={newPassword} onChangeText={setNewPassword}/>
          <TextInput style={styles.input} placeholder="Confirm New Password" placeholderTextColor="#bbb" secureTextEntry value={confirmNewPassword} onChangeText={setConfirmNewPassword}/>
          <TouchableOpacity style={styles.primaryButton} onPress={handleUpdatePassword} disabled={passwordLoading}>
            <Text style={styles.buttonText}>{passwordLoading?'Updating...':'Update Password'}</Text>
          </TouchableOpacity>
        </>
      )}

      <TouchableOpacity style={styles.signOutButton} onPress={onSignOut}>
        <Text style={styles.signOutText}>Sign Out</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  card: { backgroundColor:'#1a1a1a', borderRadius:16, padding:20, marginBottom:20 },
  title: { fontSize:24, color:'#fff', marginBottom:20, textAlign:'center', fontFamily:'Montserrat-Bold' },
  avatarContainer:{ alignSelf:'center', marginBottom:20 },
  avatar:{ width:width*0.3, height:width*0.3, borderRadius:(width*0.3)/2, backgroundColor:'#333' },
  avatarPlaceholder:{ width:width*0.3, height:width*0.3, borderRadius:(width*0.3)/2, backgroundColor:'#262626', justifyContent:'center', alignItems:'center' },
  avatarPlaceholderText:{ color:'#bbb', fontSize:40, fontFamily:'Montserrat-Regular' },
  input:{ height:48, backgroundColor:'#262626', borderRadius:12, paddingHorizontal:16, color:'#fff', marginBottom:12, fontFamily:'Montserrat-Regular' },
  primaryButton:{ backgroundColor:'#ae00ff', borderRadius:12, paddingVertical:14, alignItems:'center', marginTop:10 },
  buttonText:{ color:'#fff', fontSize:16, fontFamily:'Montserrat-Medium' },
  secondaryButton:{ alignItems:'center', marginTop:10 },
  secondaryButtonText:{ color:'#ae00ff', fontFamily:'Montserrat-Regular' },
  signOutButton:{ alignItems:'center', marginTop:16 },
  signOutText:{ color:'#ae00ff', fontFamily:'Montserrat-Regular' },
  error:{ color:'#ff4d4d', textAlign:'center', marginBottom:12, fontFamily:'Montserrat-Regular' },
});

export default ProfileCard;