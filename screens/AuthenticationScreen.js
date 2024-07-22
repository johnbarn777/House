import React, { useState, useEffect } from 'react';
import { View, TextInput, Button, Text, StyleSheet, Dimensions, ScrollView, Image, KeyboardAvoidingView, Platform } from 'react-native';
import auth from '@react-native-firebase/auth';
import { GoogleSignin, GoogleSigninButton, statusCodes } from '@react-native-google-signin/google-signin';

const AuthenticationScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    GoogleSignin.configure({
      webClientId: '1:2189201155:android:ff8a28bf9fa1ab88256336', // Replace with your web client ID from Firebase console
    });
  }, []);

  const handleSignUp = async () => {
    try {
      await auth().createUserWithEmailAndPassword(email, password);
      // User account created & signed in!
    } catch (error) {
      setError(error.message);
    }
  };

  const signInWithGoogle = async () => {
    try {
      await GoogleSignin.hasPlayServices();
      const { idToken } = await GoogleSignin.signIn();
      const googleCredential = auth.GoogleAuthProvider.credential(idToken);
      await auth().signInWithCredential(googleCredential);
    } catch (error) {
      if (error.code === statusCodes.SIGN_IN_CANCELLED) {
        setError('Sign in cancelled');
      } else if (error.code === statusCodes.IN_PROGRESS) {
        setError('Sign in in progress');
      } else if (error.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        setError('Play services not available');
      } else {
        setError(error.message);
      }
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.circleContainer}>
          <View style={styles.circle}>
            <Image source={require('../assets/logo.png')} style={styles.logo} onError={(e) => console.log(e.nativeEvent.error)} />
          </View>
        </View>
        <View style={styles.content}>
          <View style={styles.formContainer}>
            <TextInput
              style={styles.input}
              placeholder="Email"
              placeholderTextColor="#888"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
            />
            <TextInput
              style={styles.input}
              placeholder="Password"
              placeholderTextColor="#888"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
            {error ? <Text style={styles.error}>{error}</Text> : null}
            <View style={styles.buttonContainer}>
              <Button title="Sign In" onPress={handleSignUp} color="#ae00ff" />
            </View>
            <GoogleSigninButton
              style={styles.googleButton}
              size={GoogleSigninButton.Size.Icon}
              color={GoogleSigninButton.Color.Dark}
              onPress={signInWithGoogle}
            />
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const { width } = Dimensions.get('window');
const circleDiameter = width * 2;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
  },
  scrollContent: {
    flexGrow: 1,
    paddingBottom: 70,
  },
  circleContainer: {
    alignItems: 'center',
    height: width,
    marginBottom: -width / 2,
  },
  circle: {
    width: circleDiameter,
    height: circleDiameter,
    borderRadius: circleDiameter / 2,
    backgroundColor: 'black',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'absolute',
    bottom: 0,
    paddingBottom: circleDiameter / 4,
  },
  logo: {
    width: width,
    height: width,
    resizeMode: 'contain',
    marginTop: circleDiameter / 1.3,
  },
  content: {
    paddingTop: width / 2,
    paddingHorizontal: 16,
  },
  formContainer: {
    backgroundColor: '#1E1E1E',
    borderRadius: 20,
    padding: 20,
    marginHorizontal: 20,
    marginTop: 60,
    alignItems: 'center',
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 12,
    paddingHorizontal: 8,
    color: 'white',
    backgroundColor: '#1E1E1E',
    width: '80%',
  },
  error: {
    color: 'red',
    marginBottom: 12,
  },
  buttonContainer: {
    marginTop: 10,
    marginBottom: 10,
    width: '80%',
  },
  googleButton: {
    width: '80%',
    height: 48,
  },
});

export default AuthenticationScreen;
