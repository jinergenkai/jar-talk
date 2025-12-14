import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:jar_talk/router/app_router.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> _user = Rx<User?>(null);

  // Instance of GoogleSignIn
  final g_sign_in.GoogleSignIn _googleSignIn = g_sign_in.GoogleSignIn();

  User? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  @override
  void onReady() {
    super.onReady();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _authChanged);
  }

  void _authChanged(User? user) async {
    if (user == null) {
      AppRouter.router.go('/login');
    } else {
      final token = await user.getIdToken();
      print("JWT Token: $token");
      AppRouter.router.go('/shelf');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Failed",
        e.message ?? "An error occurred",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Sign Up Failed",
        e.message ?? "An error occurred",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final g_sign_in.GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn();

      if (googleUser != null) {
        // authentication is a Future, so we must await it
        final g_sign_in.GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Google Sign In Failed: ${e.message}");
      if (Get.context != null) {
        Get.snackbar(
          "Google Sign In Failed",
          e.message ?? "An error occurred",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Critical Google Sign In Error: $e");
      if (Get.context != null) {
        Get.snackbar(
          "Error",
          "Could not sign in with Google: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google Sign Out Error (Silent): $e");
    }
    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    return await _user.value?.getIdToken();
  }
}
