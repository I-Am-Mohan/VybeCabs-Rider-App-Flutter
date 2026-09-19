import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/user_model.dart';
import '../../data/auth_repository.dart';

enum AuthStatus { initial, loading, codeSent, authenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? verificationId;
  final int? resendToken;
  final String? phoneNumber;
  final String? errorMessage;
  final int resendCountdown;
  final bool isAutoDetectingOtp;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.verificationId,
    this.resendToken,
    this.phoneNumber,
    this.errorMessage,
    this.resendCountdown = 60,
    this.isAutoDetectingOtp = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? verificationId,
    int? resendToken,
    String? phoneNumber,
    String? errorMessage,
    int? resendCountdown,
    bool? isAutoDetectingOtp,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage ?? this.errorMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      isAutoDetectingOtp: isAutoDetectingOtp ?? this.isAutoDetectingOtp,
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  Timer? _countdownTimer;

  AuthController(this._repository) : super(const AuthState()) {
    checkInitialAuth();
  }

  void checkInitialAuth() {
    if (_repository.isUserLoggedIn) {
      final user = _repository.getCurrentUser();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } else {
      state = state.copyWith(status: AuthStatus.initial);
    }
  }

  Future<bool> sendOtp(String phoneNumber, {int? resendToken}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: null,
      isAutoDetectingOtp: true,
    );

    final completer = Completer<bool>();

    try {
      await _repository.sendPhoneOtp(
        phoneNumber: phoneNumber,
        resendToken: resendToken ?? state.resendToken,
        onCodeSent: (verificationId, token) {
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
            resendToken: token,
            phoneNumber: phoneNumber,
            resendCountdown: 60,
            isAutoDetectingOtp: true,
            errorMessage: null,
          );
          _startTimer();
          if (!completer.isCompleted) completer.complete(true);
        },
        onVerificationFailed: (FirebaseAuthException e) {
          final error = _mapFirebaseAuthError(e);
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: error,
            isAutoDetectingOtp: false,
          );
          if (!completer.isCompleted) completer.complete(false);
        },
        onAutoVerified: (credential) async {
          try {
            final user = await _repository.signInWithCredential(
              credential: credential,
              phoneNumber: phoneNumber,
            );
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              isAutoDetectingOtp: false,
              errorMessage: null,
            );
            if (!completer.isCompleted) completer.complete(true);
          } catch (e) {
            if (!completer.isCompleted) completer.complete(false);
          }
        },
        onAutoRetrievalTimeout: (verificationId) {
          state = state.copyWith(
            verificationId: verificationId,
            isAutoDetectingOtp: false,
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      final error = _mapFirebaseAuthError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
        isAutoDetectingOtp: false,
      );
      if (!completer.isCompleted) completer.complete(false);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred: $e',
        isAutoDetectingOtp: false,
      );
      if (!completer.isCompleted) completer.complete(false);
    }

    try {
      return await completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          if (state.status == AuthStatus.codeSent ||
              state.status == AuthStatus.authenticated) {
            return true;
          }
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                'Request timed out. Please check your internet connection and try again.',
            isAutoDetectingOtp: false,
          );
          return false;
        },
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> resendOtp() async {
    final phone = state.phoneNumber;
    if (phone == null || phone.isEmpty) return false;
    return sendOtp(phone, resendToken: state.resendToken);
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 1) {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(resendCountdown: 0, isAutoDetectingOtp: false);
      }
    });
  }

  Future<bool> verifyOtp(String otp) async {
    final trimmedOtp = otp.trim();
    if (trimmedOtp.length != 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter the complete 6-digit OTP.',
      );
      return false;
    }

    final verificationId = state.verificationId ?? '';
    if (verificationId.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'No active OTP verification session. Please request a new code.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _repository.verifyOtpAndSignIn(
        verificationId: verificationId,
        otp: trimmedOtp,
        phoneNumber: state.phoneNumber ?? '',
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthError(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Verification failed. Please check the OTP and try again.',
      );
      return false;
    }
  }

  Future<void> updateUserName(String firstName, String lastName) async {
    await _repository.updateUserName(
      firstName: firstName,
      lastName: lastName,
    );
    final updatedUser = _repository.getCurrentUser();
    state = state.copyWith(user: updatedUser);
  }

  Future<void> signOut() async {
    _countdownTimer?.cancel();
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.initial);
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The mobile number is invalid. Please check the 10-digit number.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes before trying again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded for Firebase project. Please try again later.';
      case 'session-expired':
        return 'The verification code has expired. Please tap Resend to get a new code.';
      case 'invalid-verification-code':
        return 'Invalid 6-digit verification code. Please check and enter again.';
      case 'invalid-verification-id':
        return 'Verification session has expired. Please request a new code.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'app-not-authorized':
        return 'Firebase App verification failed. Ensure SHA-1 fingerprint is added in Firebase Console.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
