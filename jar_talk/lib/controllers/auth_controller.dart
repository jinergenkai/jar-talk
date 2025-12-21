import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:jar_talk/router/app_router.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;
import 'package:jar_talk/services/dio_client.dart';
import 'package:jar_talk/models/backend_auth_models.dart';
import 'package:jar_talk/models/auth_error.dart';
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
  final g_sign_in.GoogleSignIn _googleSignIn = g_sign_in.GoogleSignIn();

  // State
  User? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  // Loading states for different operations
  final RxBool isEmailAuthLoading = false.obs;
  final RxBool isGoogleAuthLoading = false.obs;
  final RxBool isBackendAuthLoading = false.obs;

  // Error state - use stream for better error handling
  final Rx<AuthError?> currentError = Rx<AuthError?>(null);

  // Stream controller for error events (for UI to listen)
  final _errorStreamController = StreamController<AuthError>.broadcast();
  Stream<AuthError> get errorStream => _errorStreamController.stream;

  @override
  void onReady() {
    super.onReady();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _handleAuthStateChanged);
  }

  @override
  void onClose() {
    _errorStreamController.close();
    super.onClose();
  }

  /// Handle Firebase auth state changes
  void _handleAuthStateChanged(User? user) async {
    if (user == null) {
      // User logged out
      await _handleLogout();
    } else {
      // User logged in - authenticate with backend
      await _handleLogin(user);
    }
  }

  /// Handle logout flow
  Future<void> _handleLogout() async {
    try {
      isEmailAuthLoading.value = false;
      isGoogleAuthLoading.value = false;
      isBackendAuthLoading.value = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sync with AppController
      try {
        Get.find<AppController>().logout();

        // Clean up controllers
        _cleanupControllers();
      } catch (e) {
        debugPrint("Error syncing logout: $e");
      }

      AppRouter.router.go('/login');
    } catch (e) {
      debugPrint("Error in logout handler: $e");
    }
  }

  /// Handle login flow
  Future<void> _handleLogin(User user) async {
    try {
      isBackendAuthLoading.value = true;
      currentError.value = null;

      final firebaseToken = await user.getIdToken();

      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }

      debugPrint("Firebase JWT obtained");

      // Authenticate with backend with retry logic
      await _authenticateWithBackendWithRetry(firebaseToken);

      // Navigate to shelf on success
      AppRouter.router.go('/shelf');
    } catch (e) {
      debugPrint("Login error: $e");

      // Create error
      final error = AuthError.backend(
        'Failed to authenticate with server. Please try again.',
        error: e,
      );

      currentError.value = error;
      _errorStreamController.add(error);

      // Sign out on backend auth failure
      await _auth.signOut();
    } finally {
      isBackendAuthLoading.value = false;
      isEmailAuthLoading.value = false;
      isGoogleAuthLoading.value = false;
    }
  }

  /// Authenticate with backend with retry logic
  Future<void> _authenticateWithBackendWithRetry(
    String firebaseToken, {
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        await _authenticateWithBackend(firebaseToken);
        return; // Success
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxRetries) {
          debugPrint("Backend auth attempt $attempts failed, retrying...");
          await Future.delayed(Duration(seconds: attempts));
        }
      }
    }

    // All retries failed
    throw lastException ?? Exception('Backend authentication failed');
  }

  /// Authenticate with backend
  Future<void> _authenticateWithBackend(String firebaseToken) async {
    try {
      final dio = DioClient.instance.dio;

      final response = await dio.post(
        '/auth/firebase',
        data: FirebaseAuthRequest(firebaseToken: firebaseToken).toJson(),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Backend authentication timed out');
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Save tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtFirebase', firebaseToken);
      await prefs.setString('jwtBackend', authResponse.accessToken);

      debugPrint("Backend authenticated! User ID: ${authResponse.user.id}");

      // Sync with AppController
      final userInfo = {
        'user_id': authResponse.user.id,
        'email': authResponse.user.email,
        'name': authResponse.user.username ?? 'User',
        'avatarUrl': authResponse.user.avatarUrl,
      };

      try {
        Get.find<AppController>().login(userInfo);
      } catch (e) {
        debugPrint("Error syncing with AppController: $e");
      }
    } catch (e) {
      debugPrint("Backend auth error: $e");

      // Extract error message from DioException
      String errorMessage = 'Failed to authenticate with server.';

      if (e.toString().contains('DioException')) {
        try {
          // Try to extract the actual error message from response
          final dioError = e as dynamic;
          if (dioError.response?.data != null) {
            if (dioError.response.data is Map && dioError.response.data['detail'] != null) {
              errorMessage = dioError.response.data['detail'];
            } else if (dioError.response.data is String) {
              errorMessage = dioError.response.data;
            }
          }
        } catch (parseError) {
          debugPrint("Error parsing backend error: $parseError");
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Sign in with email and password
  Future<AuthResult<User>> signInWithEmail(String email, String password) async {
    try {
      // Validate inputs
      final validationError = _validateEmailPassword(email, password);
      if (validationError != null) {
        currentError.value = validationError;
        _errorStreamController.add(validationError);
        return AuthResult.failure(validationError);
      }

      isEmailAuthLoading.value = true;
      currentError.value = null;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        final error = AuthError(
          type: AuthErrorType.unknown,
          message: 'Sign in failed. Please try again.',
        );
        currentError.value = error;
        _errorStreamController.add(error);
        return AuthResult.failure(error);
      }

      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException in signIn: ${e.code} - ${e.message}");

      final error = AuthError.fromFirebaseCode(e.code, message: e.message);
      currentError.value = error;
      _errorStreamController.add(error);

      return AuthResult.failure(error);
    } catch (e) {
      debugPrint("Unexpected error in signIn: $e");

      final error = AuthError(
        type: AuthErrorType.unknown,
        message: 'An unexpected error occurred. Please try again.',
        originalError: e,
      );
      currentError.value = error;
      _errorStreamController.add(error);

      return AuthResult.failure(error);
    } finally {
      // Only reset loading if login failed (success will be handled by _handleLogin)
      if (_auth.currentUser == null) {
        isEmailAuthLoading.value = false;
      }
    }
  }

  /// Sign up with email and password
  Future<AuthResult<User>> signUpWithEmail(String email, String password) async {
    try {
      // Validate inputs
      final validationError = _validateEmailPassword(email, password);
      if (validationError != null) {
        currentError.value = validationError;
        _errorStreamController.add(validationError);
        return AuthResult.failure(validationError);
      }

      isEmailAuthLoading.value = true;
      currentError.value = null;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        final error = AuthError(
          type: AuthErrorType.unknown,
          message: 'Sign up failed. Please try again.',
        );
        currentError.value = error;
        _errorStreamController.add(error);
        return AuthResult.failure(error);
      }

      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException in signUp: ${e.code} - ${e.message}");

      final error = AuthError.fromFirebaseCode(e.code, message: e.message);
      currentError.value = error;
      _errorStreamController.add(error);

      return AuthResult.failure(error);
    } catch (e) {
      debugPrint("Unexpected error in signUp: $e");

      final error = AuthError(
        type: AuthErrorType.unknown,
        message: 'An unexpected error occurred. Please try again.',
        originalError: e,
      );
      currentError.value = error;
      _errorStreamController.add(error);

      return AuthResult.failure(error);
    } finally {
      // Only reset loading if signup failed
      if (_auth.currentUser == null) {
        isEmailAuthLoading.value = false;
      }
    }
  }

  /// Sign in with Google
  Future<AuthResult<User>> signInWithGoogle() async {
    try {
      isGoogleAuthLoading.value = true;
      currentError.value = null;

      // Sign out first to allow user to select account
      // This prevents Google from auto-selecting the last used account
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint("Google sign out before sign in error (ignored): $e");
      }

      final g_sign_in.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled
        final error = AuthError(
          type: AuthErrorType.googleSignInCancelled,
          message: 'Google sign in was cancelled.',
        );
        currentError.value = error;
        return AuthResult.failure(error);
      }

      final g_sign_in.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        final error = AuthError(
          type: AuthErrorType.googleSignInFailed,
          message: 'Google sign in failed. Please try again.',
        );
        currentError.value = error;
        _errorStreamController.add(error);
        return AuthResult.failure(error);
      }

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      debugPrint("Google Sign In FirebaseAuthException: ${e.code} - ${e.message}");

      final error = AuthError.fromFirebaseCode(e.code, message: e.message);
      currentError.value = error;
      _errorStreamController.add(error);

      return AuthResult.failure(error);
    } catch (e) {
      debugPrint("Google Sign In Error: $e");

      final error = AuthError(
        type: AuthErrorType.googleSignInFailed,
        message: 'Google sign in failed. Please try again.',
        originalError: e,
      );
      currentError.value = error;
      _errorStreamController.add(error);

      return AuthResult.failure(error);
    } finally {
      // Only reset loading if signin failed
      if (_auth.currentUser == null) {
        isGoogleAuthLoading.value = false;
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google Sign Out Error: $e");
    }

    await _auth.signOut();
  }

  /// Get Firebase ID token
  Future<String?> getIdToken() async {
    return await _user.value?.getIdToken();
  }

  /// Clear current error
  void clearError() {
    currentError.value = null;
  }

  /// Validate email and password
  AuthError? _validateEmailPassword(String email, String password) {
    if (email.trim().isEmpty) {
      return AuthError.validation(
        AuthErrorType.emptyEmail,
        'Please enter your email address.',
      );
    }

    if (!GetUtils.isEmail(email.trim())) {
      return AuthError.validation(
        AuthErrorType.invalidEmail,
        'Please enter a valid email address.',
      );
    }

    if (password.isEmpty) {
      return AuthError.validation(
        AuthErrorType.emptyPassword,
        'Please enter your password.',
      );
    }

    if (password.length < 6) {
      return AuthError.validation(
        AuthErrorType.weakPassword,
        'Password must be at least 6 characters long.',
      );
    }

    return null;
  }

  /// Clean up controllers on logout
  void _cleanupControllers() {
    if (Get.isRegistered<ShelfController>()) {
      Get.delete<ShelfController>(force: true);
    }
    if (Get.isRegistered<MainWrapperController>()) {
      Get.delete<MainWrapperController>(force: true);
    }
    if (Get.isRegistered<SettingController>()) {
      Get.delete<SettingController>(force: true);
    }
    if (Get.isRegistered<SlipController>()) {
      Get.delete<SlipController>(force: true);
    }
  }

  /// Check if any auth operation is loading
  bool get isAnyLoading =>
      isEmailAuthLoading.value ||
      isGoogleAuthLoading.value ||
      isBackendAuthLoading.value;
}
