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
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _authChanged);
  }

  void _authChanged(User? user) async {
    if (user == null) {
      isLoading.value = false; // Reset loading state on logout
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
        isLoading.value = true;
        final firebaseToken = await user.getIdToken();
        print("Firebase JWT: $firebaseToken");

        if (firebaseToken != null) {
          await _authenticateWithBackend(firebaseToken);
        }

        AppRouter.router.go('/shelf');
      } catch (e) {
        print("Backend Auth Error: $e");
        isLoading.value = false; // Ensure loading is off before dialog
        Get.defaultDialog(
          title: "Connection Error",
          content: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Backend Auth Failed:\n$e",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          textConfirm: "Retry",
          textCancel: "Logout",
          confirmTextColor: Colors.white,
          onConfirm: () async {
            Get.back(); // Close dialog
            // Retry backend auth logic
            isLoading.value = true;
            // Recursive retry effectively
            _authChanged(user);
          },
          onCancel: () {
            _auth
                .signOut(); // This will trigger _authChanged(null) -> go to login
          },
        );
        // Do NOT navigate to shelf on error.
      } finally {
        // isLoading.value = false; // handled inside catch for dialog case, and end of try for success?
        // Actually, successful path goes to shelf. Loading can stay true during transition.
        // But for error, we must turn it off. Moved to catch block to be safe.
        // If we put it here, it might flicker off before navigation.
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
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.defaultDialog(
        title: "Login Failed",
        middleText: "Error: ${e.message}\nCode: ${e.code}",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      isLoading.value = false;
      Get.defaultDialog(
        title: "Login Error",
        middleText: "Unexpected error: $e",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } finally {
      if (_auth.currentUser == null) {
        isLoading.value = false;
      }
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.defaultDialog(
        title: "Sign Up Failed",
        middleText: "Error: ${e.message}\nCode: ${e.code}",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      isLoading.value = false;
      Get.defaultDialog(
        title: "Sign Up Error",
        middleText: "Unexpected error: $e",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
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
      } else {
        // User canceled
        isLoading.value = false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Google Sign In Failed: ${e.message}");
      isLoading.value = false;
      if (Get.context != null) {
        Get.defaultDialog(
          title: "Google Sign In Failed",
          middleText: "Error: ${e.message}\nCode: ${e.code}",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      debugPrint("Critical Google Sign In Error: $e");
      isLoading.value = false;
      if (Get.context != null) {
        Get.defaultDialog(
          title: "Error",
          middleText: "Could not sign in with Google: $e",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(),
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
