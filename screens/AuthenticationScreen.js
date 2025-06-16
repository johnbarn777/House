// AuthenticationScreen.js
import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  TextInput,
  Text,
  Dimensions,
  Animated,
  TouchableOpacity,
  SafeAreaView,
  Keyboard
} from 'react-native';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signInWithCredential,
  GoogleAuthProvider
} from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import { getApp } from '@react-native-firebase/app';
import {
  GoogleSignin,
  GoogleSigninButton,
  statusCodes
} from '@react-native-google-signin/google-signin';

import CommonStyles from '../src/styles/CommonStyles';

const { width } = Dimensions.get('window');
const SMALL_LOGO_SIZE = 120;
const SPLASH_LOGO_SIZE = width;
const FINAL_LOGO_Y_OFFSET = -width * 1.5;

const AuthenticationScreen = () => {
  const auth = getAuth(getApp());

  const [isSigningUp, setIsSigningUp] = useState(false);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [animationDone, setAnimationDone] = useState(false);

  const logoScale = useRef(new Animated.Value(1.2)).current;
  const logoTranslateY = useRef(new Animated.Value(0)).current;
  const formFade = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    GoogleSignin.configure({ webClientId: '1:2189201155:android:ff8a28bf9fa1ab88256336' });

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

  const handleSignUp = async () => {
    setError('');
    if (password !== confirmPassword) return setError('Passwords do not match');
    try {
      const { user } = await createUserWithEmailAndPassword(auth, email.trim(), password);
      const uid = user.uid;
      await firestore().collection('users').doc(uid).set({ name: name.trim(), phone: phone.trim() || null, houses: [] });
      console.log('✔️ user profile in Firestore:', (await firestore().collection('users').doc(uid).get()).data());
    } catch (e) {
      console.error('❌ signup error:', e);
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
      setError(e.code === statusCodes.SIGN_IN_CANCELLED ? 'Cancelled' : e.message);
    }
  };

  return (
    <SafeAreaView style={CommonStyles.safe}>
      <View style={CommonStyles.container}>
        <Animated.Image
          source={require('../src/assets/logo.png')}
          style={[CommonStyles.logo, { transform: [{ scale: logoScale }, { translateY: logoTranslateY }] }]}
        />
        {!animationDone && <Text style={styles.splashText}>Efficient Living Loading</Text>}

        {!animationDone && <Text style={CommonStyles.splashText}>Efficient Living Loading</Text>}

        {animationDone && (
          <Animated.View style={[CommonStyles.formWrapper, { opacity: formFade }]}>            
            <KeyboardAwareScrollView contentContainerStyle={CommonStyles.scrollContent} enableOnAndroid extraScrollHeight={0} keyboardOpeningTime={0}>
              <View style={CommonStyles.card}>
                <Text style={CommonStyles.title}>{isSigningUp ? 'Create Account' : 'Welcome Back'}</Text>

                {isSigningUp && (
                  <>
                    <TextInput style={CommonStyles.input} placeholder="Full Name" placeholderTextColor="#bbb" value={name} onChangeText={setName} />
                    <TextInput style={CommonStyles.input} placeholder="Phone (optional)" placeholderTextColor="#bbb" value={phone} onChangeText={setPhone} keyboardType="phone-pad" />
                  </>
                )}

                <TextInput style={CommonStyles.input} placeholder="Email" placeholderTextColor="#bbb" value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" />
                <TextInput style={CommonStyles.input} placeholder="Password" placeholderTextColor="#bbb" textContentType="oneTimeCode" value={password} onChangeText={setPassword} secureTextEntry blurOnSubmit={false} onSubmitEditing={() => Keyboard.dismiss()} />
                {isSigningUp && <TextInput style={CommonStyles.input} placeholder="Confirm Password" placeholderTextColor="#bbb" textContentType="oneTimeCode" value={confirmPassword} onChangeText={setConfirmPassword} secureTextEntry blurOnSubmit={false} onSubmitEditing={() => Keyboard.dismiss()} />}

                {error && <Text style={CommonStyles.error}>{error}</Text>}

                <TouchableOpacity style={CommonStyles.primaryButton} onPress={isSigningUp ? handleSignUp : handleSignIn} activeOpacity={0.8}>
                  <Text style={CommonStyles.buttonText}>{isSigningUp ? 'Sign Up' : 'Sign In'}</Text>
                </TouchableOpacity>

                {!isSigningUp && <GoogleSigninButton style={CommonStyles.googleButton} size={GoogleSigninButton.Size.Wide} color={GoogleSigninButton.Color.Light} onPress={signInWithGoogle} />}

                <TouchableOpacity onPress={() => { setError(''); setIsSigningUp(!isSigningUp); }}>
                  <Text style={CommonStyles.toggleLink}>{isSigningUp ? 'Have an account? Sign In' : 'New here? Create account'}</Text>
                </TouchableOpacity>
              </View>
            </KeyboardAwareScrollView>
          </Animated.View>
        )}
      </View>
    </SafeAreaView>
  );
};

export default AuthenticationScreen;
