/// Authentication error types
enum AuthErrorType {
  // Validation errors
  emptyEmail,
  emptyPassword,
  invalidEmail,
  weakPassword,

  // Firebase errors
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  tooManyRequests,
  userDisabled,
  operationNotAllowed,
  networkError,

  // Backend errors
  backendAuthFailed,
  backendTimeout,
  backendNetworkError,

  // OAuth errors
  googleSignInCancelled,
  googleSignInFailed,
  appleSignInFailed,

  // Unknown
  unknown,
}

/// Authentication error model
class AuthError {
  final AuthErrorType type;
  final String message;
  final String? technicalDetails;
  final dynamic originalError;

  AuthError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.originalError,
  });

  /// Create AuthError from Firebase error code
  factory AuthError.fromFirebaseCode(String code, {String? message}) {
    AuthErrorType type;
    String userMessage;

    switch (code) {
      case 'user-not-found':
        type = AuthErrorType.userNotFound;
        userMessage = 'No account found with this email.';
        break;
      case 'wrong-password':
        type = AuthErrorType.wrongPassword;
        userMessage = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        type = AuthErrorType.emailAlreadyInUse;
        userMessage = 'This email is already registered.';
        break;
      case 'too-many-requests':
        type = AuthErrorType.tooManyRequests;
        userMessage = 'Too many attempts. Please try again later.';
        break;
      case 'user-disabled':
        type = AuthErrorType.userDisabled;
        userMessage = 'This account has been disabled.';
        break;
      case 'operation-not-allowed':
        type = AuthErrorType.operationNotAllowed;
        userMessage = 'This sign-in method is not enabled.';
        break;
      case 'network-request-failed':
        type = AuthErrorType.networkError;
        userMessage = 'Network error. Please check your connection.';
        break;
      default:
        type = AuthErrorType.unknown;
        userMessage = message ?? 'An unexpected error occurred.';
    }

    return AuthError(
      type: type,
      message: userMessage,
      technicalDetails: code,
    );
  }

  /// Create validation error
  factory AuthError.validation(AuthErrorType type, String message) {
    return AuthError(
      type: type,
      message: message,
    );
  }

  /// Create backend error
  factory AuthError.backend(String message, {dynamic error}) {
    return AuthError(
      type: AuthErrorType.backendAuthFailed,
      message: message,
      originalError: error,
    );
  }

  @override
  String toString() {
    return 'AuthError(type: $type, message: $message)';
  }
}

/// Authentication result
class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final AuthError? error;

  AuthResult.success(this.data)
      : isSuccess = true,
        error = null;

  AuthResult.failure(this.error)
      : isSuccess = false,
        data = null;
}
