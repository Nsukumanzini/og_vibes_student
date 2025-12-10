import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  const AuthResult({required this.credential, required this.needsVerification});

  final UserCredential credential;
  final bool needsVerification;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String campus,
    required String department,
    required String level,
    required String studentType,
    required String gender,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Unable to create account. Please try again.',
      );
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email.trim(),
      'name': name.trim(),
      'surname': surname.trim(),
      'campus': campus,
      'department': department,
      'level': level,
      'studentType': studentType,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();

    return AuthResult(credential: credential, needsVerification: true);
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Unable to sign in. Please try again.',
      );
    }

    final needsVerification = user.emailVerified != true;
    return AuthResult(
      credential: credential,
      needsVerification: needsVerification,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
