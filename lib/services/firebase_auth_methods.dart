import 'package:flutter/foundation.dart' show kIsWeb;
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_firebase_auth/utils/showOtpDialog.dart';
import 'package:flutter_firebase_auth/utils/showSnackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  User get user => _auth.currentUser!;

  // STATE PERSISTENCE
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();
    // FirebaseAuth.instance.userChanges(); OR FirebaseAuth.instance.idTokenChanges();


  // EMAIL SIGN UP ===================================
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await sendEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // EMAIL LOGIN =====================================================
  Future<void> loginWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        await sendEmailVerification(context);
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // EMAIL VERIFICATION =============================================
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification sent!');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // PHONE SIGN IN      ===========================================================
  Future<void> phoneSignIn(
    BuildContext context,
    String phoneNumber,
  ) async {
    TextEditingController codeController = TextEditingController();
    if (kIsWeb) {
      // For WEB.................
      ConfirmationResult result = await _auth.signInWithPhoneNumber(phoneNumber);

      // Display dialog box to accept OTP
          showOTPDialog(
            context: context,
            codeController: codeController,
            onPressed: () {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: result.verificationId,
                smsCode: codeController.text.trim(),
              );

              _auth.signInWithCredential(credential);
              Navigator.of(context).pop();
            },
          );
    } else {
      // For Android, iOS
      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          debugPrint(e.message!);
          showSnackBar(context, e.message!);
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Display dialog box to accept OTP
          showOTPDialog(
            context: context,
            codeController: codeController,
            onPressed: () {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: codeController.text.trim(),
              );

              _auth.signInWithCredential(credential);
              Navigator.of(context).pop();
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    }
  }


  // GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');

        await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
          // Create a new credential
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          // if you want to do specific task like storing information in firestore
          // only for new users using google sign in (since there are no two options
          // for google sign in and google sign up, only one as of now),
          // do the following:

          // if (userCredential.user != null) {
          //   if (userCredential.additionalUserInfo!.isNewUser) {}
          // }
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('ERROR === ${e.message!}');
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  // FACEBOOK SIGN IN
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      await _auth.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  // ANONYMOUS SIGN IN
  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      _auth.signOut();
    } on FirebaseAuthException  catch (e) {
      showSnackBar(context, e.message!);
    }
    
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount(BuildContext context)async {
    try {
      _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
