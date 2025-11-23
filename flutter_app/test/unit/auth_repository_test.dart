import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_app/core/services/auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  UserCredential,
  User,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  AuthCredential,
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthRepository', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('signInWithEmailAndPassword calls FirebaseAuth', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authRepository.signInWithEmailAndPassword(
        email,
        password,
      );

      expect(result, mockUser);
      verify(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
    });

    test('createUserWithEmailAndPassword calls FirebaseAuth', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authRepository.createUserWithEmailAndPassword(
        email,
        password,
      );

      expect(result, mockUser);
      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
    });

    test('signOut calls both providers', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await authRepository.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });
}
