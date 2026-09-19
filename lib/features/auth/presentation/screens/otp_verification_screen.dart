import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../controllers/auth_controller.dart';
import 'enter_name_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _showManualWarning = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (mounted) setState(() {});
      });
    }

    // Auto-focus first input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });

    // Show manual notice after 5 seconds if code not detected automatically
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showManualWarning = true);
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');

    // Handle full paste or multi-character input
    if (clean.length > 2 || (clean.length > 1 && index == 0)) {
      for (int i = 0; i < clean.length && (index + i) < 6; i++) {
        _controllers[index + i].text = clean[i];
      }
      final nextFocus = (index + clean.length).clamp(0, 5);
      if (nextFocus < 5) {
        _focusNodes[nextFocus].requestFocus();
      } else {
        _focusNodes[5].unfocus();
      }
      setState(() {});
      if (_otp.length == 6) {
        _onVerify();
      }
      return;
    }

    if (clean.length == 2) {
      // User typed over an existing character
      final newChar = clean[clean.length - 1];
      _controllers[index].text = newChar;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otp.length == 6) {
          _onVerify();
        }
      }
      setState(() {});
      return;
    }

    if (clean.isNotEmpty) {
      _controllers[index].text = clean;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otp.length == 6) {
          _onVerify();
        }
      }
    } else {
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  void _onVerify() async {
    final otp = _otp.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the verification code'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      final user = ref.read(authControllerProvider).user;
      final hasName =
          (user?.firstName.isNotEmpty ?? false) && user?.firstName != '';
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              hasName ? const HomeScreen() : const EnterNameScreen(),
        ),
      );
    } else {
      final error =
          ref.read(authControllerProvider).errorMessage ??
          'Invalid OTP code. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _formatMaskedPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final last10 = digits.substring(digits.length - 10);
      final visiblePrefix = last10.substring(0, 5);
      return '+91 $visiblePrefix xxxxx';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isOtpComplete = _otp.length == 6;

    // Listen for automatic verification completion (Android SMS retriever/instant verification)
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && mounted) {
        final user = next.user;
        final hasName =
            (user?.firstName.isNotEmpty ?? false) && user?.firstName != '';
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                hasName ? const HomeScreen() : const EnterNameScreen(),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 15,
                  color: AppColors.iconPrimary,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png',
          width: 26,
          height: 26,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.local_taxi, size: 24, color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'We sent a 6-digit code to ',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: _formatMaskedPhone(
                              widget.phoneNumber.isNotEmpty
                                  ? widget.phoneNumber
                                  : '+91 62897xxxxx',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Change number',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Verification Code',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Responsive 6 OTP Boxes
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final boxWidth = ((availableWidth - (5 * 8)) / 6).clamp(
                    42.0,
                    50.0,
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final isFocused = _focusNodes[index].hasFocus;
                      final hasValue = _controllers[index].text.isNotEmpty;

                      return GestureDetector(
                        onTap: () => _focusNodes[index].requestFocus(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: boxWidth,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFocused
                                  ? AppColors.primary
                                  : (hasValue
                                        ? AppColors.borderStrong
                                        : AppColors.border),
                              width: isFocused ? 1.8 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              cursorColor: AppColors.primary,
                              cursorWidth: 2.0,
                              cursorHeight: 24.0,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: false,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) => _onDigitChanged(index, val),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 18),
              // Resend text
              Row(
                children: [
                  Text(
                    'Didn’t receive the code? ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: authState.resendCountdown == 0
                        ? () => ref
                              .read(authControllerProvider.notifier)
                              .resendOtp()
                        : null,
                    child: Text(
                      authState.resendCountdown > 0
                          ? 'Resend available in ${authState.resendCountdown}s'
                          : 'Resend now',
                      style: AppTypography.bodySmall.copyWith(
                        color: authState.resendCountdown > 0
                            ? AppColors.textMuted
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Auto-detect OTP spinner
              if (authState.isAutoDetectingOtp) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Trying to auto-detect OTP',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // Error banner if any error occurred
              if (authState.errorMessage != null &&
                  authState.status == AuthStatus.error) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else if (_showManualWarning &&
                  !authState.isAutoDetectingOtp &&
                  _otp.isEmpty) ...[
                // Manual warning notice
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showManualWarning ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warningBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Couldn’t detect the code. Enter it manually.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.warningText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Spacer(),
              // Verify and continue button
              VybeButton(
                label: 'Verify and continue',
                isLoading: isLoading,
                onPressed: _onVerify,
                variant: isOtpComplete
                    ? VybeButtonVariant.primary
                    : VybeButtonVariant.primary,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
