import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AuthRepository(FirebaseAuth.instance, storage);
});

class AuthRepository {
  final FirebaseAuth _auth;
  final LocalStorageService _storage;

  AuthRepository(this._auth, this._storage);

  User? get currentFirebaseUser => _auth.currentUser;

  bool get isUserLoggedIn => _storage.isLoggedIn && _auth.currentUser != null;

  UserModel getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    final storedName = _storage.userName.trim();
    final firebaseDisplayName = (firebaseUser?.displayName ?? '').trim();
    final displayName = storedName.isNotEmpty ? storedName : firebaseDisplayName;

    final nameParts = displayName.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final phone = _storage.userPhone.isNotEmpty
        ? _storage.userPhone
        : (firebaseUser?.phoneNumber ?? '');
    final sanitizedName = displayName.isNotEmpty
        ? displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '')
        : (firebaseUser?.uid.isNotEmpty == true ? firebaseUser!.uid.substring(0, 6) : 'rider');

    return UserModel(
      id: firebaseUser?.uid ?? 'vybe_user_local_1',
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: firebaseUser?.email ?? '$sanitizedName@vybecabs.com',
      isVerified: true,
    );
  }

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    int? resendToken,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    required Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    final normalizedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');
    await _auth.verifyPhoneNumber(
      phoneNumber: normalizedNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? token) {
        onCodeSent(verificationId, token);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onAutoRetrievalTimeout(verificationId);
      },
    );
  }

  Future<UserModel> verifyOtpAndSignIn({
    required String verificationId,
    required String otp,
    required String phoneNumber,
  }) async {
    if (verificationId.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-verification-id',
        message: 'No verification session found. Please request a new OTP.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    return signInWithCredential(
      credential: credential,
      phoneNumber: phoneNumber,
    );
  }

  Future<UserModel> signInWithCredential({
    required PhoneAuthCredential credential,
    required String phoneNumber,
  }) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '');
    await _storage.setUserPhone(normalizedPhone);
    await _storage.setLoggedIn(true);

    if (firebaseUser?.displayName != null && firebaseUser!.displayName!.trim().isNotEmpty) {
      await _storage.setUserName(firebaseUser.displayName!.trim());
    }

    return getCurrentUser();
  }

  Future<void> updateUserName({
    required String firstName,
    required String lastName,
  }) async {
    final fullName = '$firstName $lastName'.trim();
    await _storage.setUserName(fullName);
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(fullName);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    await _storage.clearAuth();
  }
}
