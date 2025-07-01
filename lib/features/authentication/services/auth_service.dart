import 'package:bookstore/common/exceptions/custom_exception.dart';
import 'package:bookstore/features/authentication/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _db;

  AuthService(this._firebaseAuth, this._db);

  Future<void> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw BookStoreAppException('Email is already in use');
      } else if (e.code == 'weak-password') {
        throw BookStoreAppException('Password is too weak');
      } else {
        throw BookStoreAppException(
          e.message ?? 'An error occurred during sign up',
        );
      }
    } catch (e) {
      throw BookStoreAppException('Something went wrong, please try again');
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user =
          await _db.collection('users').doc(userCredential.user?.uid).get();
      if (!user.exists) {
        throw BookStoreAppException('User does not exist');
      }

      final userData = UserModel.fromJson(user.data()!);
      return userData;
    } on FirebaseAuthException {
      throw BookStoreAppException('Incorrect email or password');
    } catch (e) {
      throw BookStoreAppException('Something went wrong, please try again');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      if (googleAuth == null) {
        throw BookStoreAppException('Google sign-in aborted');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw BookStoreAppException('User not found after Google sign-in');
      }

      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _db.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw BookStoreAppException(
          'Account already exists with a different credential',
        );
      } else {
        throw BookStoreAppException(
          e.message ?? 'An error occurred during Google sign-in',
        );
      }
    } catch (e) {
      throw BookStoreAppException('Something went wrong, please try again');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw BookStoreAppException('No user found for this email');
      } else {
        throw BookStoreAppException(
          e.message ?? 'An error occurred while resetting password',
        );
      }
    } catch (e) {
      throw BookStoreAppException('Something went wrong, please try again');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
