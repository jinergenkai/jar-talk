import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:jar_talk/router/app_router.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;
import 'package:jar_talk/services/dio_client.dart';
import 'package:jar_talk/models/backend_auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jar_talk/controllers/app_controller.dart';
import 'package:jar_talk/controllers/shelf_controller.dart';
import 'package:jar_talk/controllers/main_wrapper_controller.dart';
import 'package:jar_talk/controllers/setting_controller.dart';
import 'package:jar_talk/controllers/slip_controller.dart';

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear tokens on logout

      // Sync with AppController
      try {
        Get.find<AppController>().logout();
        // Remove ShelfController to force reload on next login
        if (Get.isRegistered<ShelfController>()) {
          Get.delete<ShelfController>(force: true);
        }
        if (Get.isRegistered<MainWrapperController>()) {
          Get.delete<MainWrapperController>(force: true);
        }
        // SettingController is defined in setting_controller.dart
        if (Get.isRegistered<SettingController>()) {
          Get.delete<SettingController>(force: true);
        }
        if (Get.isRegistered<SlipController>()) {
          Get.delete<SlipController>(force: true);
        }
      } catch (e) {
        print("Error syncing logout with AppController: $e");
      }

      AppRouter.router.go('/login');
    } else {
      try {
        final firebaseToken = await user.getIdToken();
        print("Firebase JWT: $firebaseToken");

        if (firebaseToken != null) {
          await _authenticateWithBackend(firebaseToken);
        }

        AppRouter.router.go('/shelf');
      } catch (e) {
        print("Backend Auth Error: $e");
        // Still navigate to shelf or handle error appropriately?
        // Maybe stay on login if backend auth is strict requirement?
        // For now, let's allow access but log error (or maybe show snackbar)
        Get.snackbar(
          "Connection Error",
          "Could not connect to backend server. Some features may be unavailable.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withOpacity(0.8),
          colorText: Colors.white,
        );
        AppRouter.router.go('/shelf');
      }
    }
  }

  Future<void> _authenticateWithBackend(String firebaseToken) async {
    try {
      final dio = DioClient.instance.dio;
      final response = await dio.post(
        '/auth/firebase',
        data: FirebaseAuthRequest(firebaseToken: firebaseToken).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtFirebase', firebaseToken);
      await prefs.setString('jwtBackend', authResponse.accessToken);

      print("Backend Authenticated! User ID: ${authResponse.user.id}");
      print("Backend Authenticated! Token: ${authResponse.accessToken}");

      // Sync with AppController
      // Map UseResponse to AppController's userInfo map structure
      final userInfo = {
        'id': authResponse.user.id,
        'email': authResponse.user.email,
        'name': authResponse.user.username ?? 'User', // Map username to name
        'avatarUrl': authResponse.user.avatarUrl,
      };

      try {
        Get.find<AppController>().login(userInfo);
      } catch (e) {
        print("Error syncing login with AppController: $e");
      }
    } catch (e) {
      print("Failed to authenticate with backend: $e");
      rethrow;
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
