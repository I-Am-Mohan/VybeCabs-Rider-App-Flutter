import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bottom_sheet.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../../domain/ride_state.dart';
import '../controllers/tracking_controller.dart';

class PaymentBottomSheet extends ConsumerStatefulWidget {
  final ActiveRideState ride;

  const PaymentBottomSheet({super.key, required this.ride});

  static Future<void> show(BuildContext context, {required ActiveRideState ride}) {
    return VybeBottomSheet.show(
      context: context,
      builder: (ctx) => PaymentBottomSheet(ride: ride),
    );
  }

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selectedMethod = PaymentMethod.upi;
  bool _isProcessing = false;
  bool _isSuccess = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.ride.paymentMethod;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPay() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    await ref
        .read(trackingControllerProvider.notifier)
        .processPayment(_selectedMethod);

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    _animController.forward();

    // Auto-close after celebration
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.successBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x331FA64A),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 50,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.ride.fare.toStringAsFixed(0)} paid via ${_selectedMethod.name.toUpperCase()}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    return VybeBottomSheet(
      title: 'Select Payment Option',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Fare Highlight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Amount',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.ride.vehicleTier.name} ride',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${widget.ride.fare.toStringAsFixed(0)}',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Payment Methods',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Option 1: UPI
          _buildPaymentOption(
            method: PaymentMethod.upi,
            icon: Icons.qr_code_2_rounded,
            title: 'UPI (Google Pay / PhonePe / Paytm)',
            subtitle: 'Instant auto-debit or scan QR',
          ),
          const SizedBox(height: 10),

          // Option 2: Card
          _buildPaymentOption(
            method: PaymentMethod.card,
            icon: Icons.credit_card_rounded,
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, RuPay & Amex',
          ),
          const SizedBox(height: 10),

          // Option 3: Cash
          _buildPaymentOption(
            method: PaymentMethod.cash,
            icon: Icons.money_rounded,
            title: 'Cash Payment',
            subtitle: 'Pay exact cash directly to the driver',
          ),
          const SizedBox(height: 24),

          // Pay CTA
          VybeButton(
            label: _selectedMethod == PaymentMethod.cash
                ? 'Confirm Cash Payment'
                : 'Pay ₹${widget.ride.fare.toStringAsFixed(0)}',
            isLoading: _isProcessing,
            onPressed: _onPay,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySoft.withValues(alpha: 0.3)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : AppColors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.iconSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderStrong,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
