// CommonStyles.js
import { StyleSheet, Dimensions } from 'react-native';

const { width } = Dimensions.get('window');
const SMALL_LOGO_SIZE = 120;
const SPLASH_LOGO_SIZE = width;

export default StyleSheet.create({
  // Safe area background
  safe: { flex: 1, backgroundColor: '#0A0F1F' },

  // Centered full-screen container with black background
  container: { flex: 1, backgroundColor: '#000', alignItems: 'center', justifyContent: 'center' },

  // Utility for centering content
  centerContent: { justifyContent: 'center', alignItems: 'center' },

  // Utility for full flex
  flex: { flex: 1 },

  // Card styles
  card: {
    backgroundColor: '#1a1a1a',
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.5,
    shadowRadius: 4,
    elevation: 5,
  },

  // Typography
  title: { fontSize: 24, color: '#fff', fontWeight: '600', marginBottom: 20, textAlign: 'center', fontFamily: 'Montserrat-Bold' },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '500', fontFamily: 'Montserrat-Medium' },
  toggleLink: { color: '#ae00ff', textAlign: 'center', marginTop: 10, fontSize: 14, fontFamily: 'Montserrat-Regular' },
  error: { color: '#ff4d4d', textAlign: 'center', marginBottom: 12, fontFamily: 'Montserrat-Regular' },

  // Inputs & Buttons
  input: { height: 48, backgroundColor: '#262626', borderRadius: 12, paddingHorizontal: 16, color: '#fff', marginBottom: 12, fontFamily: 'Montserrat-Regular' },
  primaryButton: { backgroundColor: '#ae00ff', borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 10, marginBottom: 20 },

  // Authentication-specific
  logo: { width: SPLASH_LOGO_SIZE, height: SPLASH_LOGO_SIZE, resizeMode: 'contain' },
  splashText: { color: '#ae00ff', fontSize: 22, marginTop: 20, fontFamily: 'Montserrat-Bold', textAlign: 'center' },
  formWrapper: { position: 'absolute', bottom: 0, width: '100%' },
  scrollContent: { flexGrow: 1, justifyContent: 'flex-end', padding: 20 },
  googleButton: { width: '100%', height: 48, marginBottom: 20 },

  // ChoresScreen-specific
  loadingText: { color: '#fff', fontSize: 18, fontFamily: 'Montserrat-Regular' },
  listContainer: { flex: 1, padding: 16 },
  inputContainer: { flexDirection: 'row', padding: 16, borderTopWidth: 1, borderColor: '#222', backgroundColor: '#000', alignItems: 'center' },
  inputOverride: { flex: 1, marginRight: 8, borderRadius: 24 },
  pickerToggle: { borderRadius: 24, justifyContent: 'center', paddingHorizontal: 16, marginRight: 8, height: 48 },
  pickerToggleText: { color: '#fff' },
  countInput: { width: 60, marginRight: 8 },

  // Dialog-specific
  overlay: { position: 'absolute', top: 0, bottom: 0, left: 0, right: 0, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center' },
  disabledButton: { backgroundColor: '#444' },
  closeButton: { backgroundColor: '#8B0000' },

  // HouseScreen-specific
  scrollFlexGrow: { flexGrow: 1 },
  circleContainer: { alignItems: 'center', height: width, marginBottom: -width / 2 },
  circle: { width: width * 2, height: width * 2, borderRadius: width, backgroundColor: '#fff', justifyContent: 'flex-end', alignItems: 'center', position: 'absolute', bottom: 0, paddingBottom: (width * 2) / 4 },
  houseName: { fontSize: 24, color: '#000', fontFamily: 'Montserrat-Bold' },
  houseCode: { fontSize: 16, color: '#555', marginTop: 4, fontFamily: 'Montserrat-Regular' },
  content: { paddingTop: width / 2, paddingHorizontal: 16 },
  module: { backgroundColor: '#1E1E1E', borderRadius: 8, padding: 16, marginBottom: 16 },
  moduleTitle: { fontSize: 20, color: '#fff', marginBottom: 8, fontFamily: 'Montserrat-Medium' },
  moduleContent: { fontSize: 16, color: '#fff', fontFamily: 'Montserrat-Regular' },
  addButton: { position: 'absolute', right: 20, backgroundColor: '#ae00ff', borderRadius: 50, padding: 10, zIndex: 1000, elevation: 1000 },

  // SettingsScreen-specific
  settingsScrollContent: { flexGrow: 1, justifyContent: 'center', padding: 20 }  
});
