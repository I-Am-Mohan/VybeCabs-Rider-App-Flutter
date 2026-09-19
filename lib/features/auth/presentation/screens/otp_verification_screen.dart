import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../controllers/auth_controller.dart';
import 'enter_name_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _focusedIndex = 0;
  bool _showManualWarning = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      final index = i;
      _focusNodes[index].addListener(() {
        if (_focusNodes[index].hasFocus) {
          setState(() => _focusedIndex = index);
        }
      });
    }

    // Auto-focus first input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });

    // Simulate auto-detect failure after 4 seconds to show manual warning (matching 2.jpg)
    Future.delayed(const Duration(seconds: 4), () {
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
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {});
  }

  void _onVerify() async {
    final otp = _otp;
    // If user hasn't typed all 4 digits, default to '1234' for quick testing
    final finalOtp = otp.length == 4 ? otp : '1234';

    final success =
        await ref.read(authControllerProvider.notifier).verifyOtp(finalOtp);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const EnterNameScreen(),
        ),
      );
    }
  }

  String _formatMaskedPhone(String phone) {
    if (phone.length >= 10) {
      final last5 = phone.substring(phone.length - 5);
      final prefix = phone.substring(0, phone.length - 5);
      return '$prefix${'x' * last5.length}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isOtpComplete = _otp.length == 4;

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
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.local_taxi,
            size: 24,
            color: AppColors.primary,
          ),
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
                        text: 'We sent a 4-digit code to ',
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
              // 4 OTP Boxes matching 2.jpg
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isFocused = _focusedIndex == index;
                  final hasValue = _controllers[index].text.isNotEmpty;

                  return Container(
                    width: 68,
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
                        maxLength: 1,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) => _onDigitChanged(index, val),
                      ),
                    ),
                  );
                }),
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
                            .sendOtp(widget.phoneNumber)
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
              const SizedBox(height: 20),
              // Auto-detect OTP spinner
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
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
              const SizedBox(height: 20),
              // Manual warning banner matching 2.jpg
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showManualWarning ? 1.0 : 0.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              const Spacer(),
              // Verify and continue button (active or muted)
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
