// AuthenticationScreen.js
// To use custom fonts:
// 1. Place your .ttf files (e.g., Montserrat-Bold.ttf) into ./assets/fonts/
// 2. Create or update react-native.config.js:
//    module.exports = { assets: ['./assets/fonts/'] };
// 3. Run: npx react-native-asset
// 4. Rebuild your app. Then reference via fontFamily in styles.

import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  TextInput,
  Text,
  StyleSheet,
  Dimensions,
  ScrollView,
  Animated,
  KeyboardAvoidingView,
  Platform,
  TouchableOpacity,
  SafeAreaView
} from 'react-native';
import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, signInWithCredential, GoogleAuthProvider } from '@react-native-firebase/auth';
import { getApp } from '@react-native-firebase/app';
import { GoogleSignin, GoogleSigninButton, statusCodes } from '@react-native-google-signin/google-signin';

const { width } = Dimensions.get('window');
const SMALL_LOGO_SIZE = 120;
const SPLASH_LOGO_SIZE = width;
const FINAL_LOGO_Y_OFFSET = -width;

const AuthenticationScreen = () => {
  // Initialize Firebase Auth instance
  const auth = getAuth(getApp());

  const [isSigningUp, setIsSigningUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [animationDone, setAnimationDone] = useState(false);

  // Animated values
  const logoScale = useRef(new Animated.Value(1.2)).current;
  const logoTranslateY = useRef(new Animated.Value(0)).current;
  const formFade = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    GoogleSignin.configure({ webClientId: '1:2189201155:android:ff8a28bf9fa1ab88256336' });

    // Zoom-out & move-up splash animation
    Animated.sequence([
      Animated.delay(1500),
      Animated.parallel([
        Animated.timing(logoScale, { toValue: SMALL_LOGO_SIZE / SPLASH_LOGO_SIZE, duration: 800, useNativeDriver: true }),
        Animated.timing(logoTranslateY, { toValue: FINAL_LOGO_Y_OFFSET, duration: 800, useNativeDriver: true })
      ])
    ]).start(() => {
      setAnimationDone(true);
      Animated.timing(formFade, { toValue: 1, duration: 500, useNativeDriver: true }).start();
    });
  }, []);

  // Auth handlers
  const handleSignUp = async () => {
    setError('');
    if (password !== confirmPassword) return setError('Passwords do not match');
    try {
      await createUserWithEmailAndPassword(auth, email.trim(), password);
    } catch (e) {
      setError(e.message);
    }
  };

  const handleSignIn = async () => {
    setError('');
    try {
      await signInWithEmailAndPassword(auth, email.trim(), password);
    } catch (e) {
      setError(e.message);
    }
  };

  const signInWithGoogle = async () => {
    setError('');
    try {
      await GoogleSignin.hasPlayServices();
      const { idToken } = await GoogleSignin.signIn();
      const credential = GoogleAuthProvider.credential(idToken);
      await signInWithCredential(auth, credential);
    } catch (e) {
      const msg = e.code === statusCodes.SIGN_IN_CANCELLED ? 'Cancelled' : e.message;
      setError(msg);
    }
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.container}>
        {/* Splash logo */}
        <Animated.Image
          source={require('../assets/logo.png')}
          style={[
            styles.logo,
            {
              transform: [
                { scale: logoScale },
                { translateY: logoTranslateY }
              ]
            }
          ]}
        />

        {/* Splash text */}
        {!animationDone && (
          <Text style={styles.splashText}>Efficient Living Loading</Text>
        )}

        {/* Auth form */}
        {animationDone && (
          <Animated.View style={[styles.formWrapper, { opacity: formFade }]}>            
            <KeyboardAvoidingView
              behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
              style={styles.flex}
            >
              <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
                <View style={styles.card}>
                  <Text style={styles.title}>{isSigningUp ? 'Create Account' : 'Welcome Back'}</Text>

                  <TextInput style={styles.input} placeholder="Email" placeholderTextColor="#bbb"
                    value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" />
                  <TextInput style={styles.input} placeholder="Password" placeholderTextColor="#bbb"
                    value={password} onChangeText={setPassword} secureTextEntry />
                  {isSigningUp && <TextInput style={styles.input} placeholder="Confirm Password" placeholderTextColor="#bbb"
                    value={confirmPassword} onChangeText={setConfirmPassword} secureTextEntry />}

                  {error ? <Text style={styles.error}>{error}</Text> : null}

                  <TouchableOpacity style={styles.primaryButton} onPress={isSigningUp ? handleSignUp : handleSignIn} activeOpacity={0.8}>
                    <Text style={styles.buttonText}>{isSigningUp ? 'Sign Up' : 'Sign In'}</Text>
                  </TouchableOpacity>

                  {!isSigningUp && <GoogleSigninButton style={styles.googleButton} size={GoogleSigninButton.Size.Wide}
                    color={GoogleSigninButton.Color.Light} onPress={signInWithGoogle} />}

                  <TouchableOpacity onPress={() => { setError(''); setIsSigningUp(!isSigningUp); }}>
                    <Text style={styles.toggleLink}>{isSigningUp ? 'Have an account? Sign In' : 'New here? Create account'}</Text>
                  </TouchableOpacity>
                </View>
              </ScrollView>
            </KeyboardAvoidingView>
          </Animated.View>
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#000' },
  container: { flex: 1, backgroundColor: '#000', alignItems: 'center', justifyContent: 'center' },
  logo: { width: SPLASH_LOGO_SIZE, height: SPLASH_LOGO_SIZE, resizeMode: 'contain' },
  splashText: { color: '#ae00ff', fontSize: 22, marginTop: 20, fontFamily: 'Montserrat-Bold' },
  flex: { flex: 1 },
  formWrapper: { position: 'absolute', bottom: 0, width: '100%', flex: 1 },
  scrollContent: { flexGrow: 1, justifyContent: 'flex-end', padding: 20 },
  card: { backgroundColor: '#1a1a1a', borderRadius: 16, padding: 20, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.5, shadowRadius: 4, elevation: 5 },
  title: { fontSize: 24, color: '#fff', fontWeight: '600', marginBottom: 20, textAlign: 'center', fontFamily: 'Montserrat-Bold' },
  input: { height: 48, backgroundColor: '#262626', borderRadius: 12, paddingHorizontal: 16, color: '#fff', marginBottom: 12, fontFamily: 'Montserrat-Regular' },
  primaryButton: { backgroundColor: '#ae00ff', borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 10, marginBottom: 20 },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '500', fontFamily: 'Montserrat-Medium' },
  googleButton: { width: '100%', height: 48, marginBottom: 20 },
  toggleLink: { color: '#ae00ff', textAlign: 'center', marginTop: 10, fontSize: 14, fontFamily: 'Montserrat-Regular' },
  error: { color: '#ff4d4d', textAlign: 'center', marginBottom: 12, fontFamily: 'Montserrat-Regular' }
});

export default AuthenticationScreen;
