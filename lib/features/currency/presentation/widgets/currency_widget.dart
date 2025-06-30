import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../cubit/currency_cubit.dart';
import '../cubit/currency_state.dart';

class CurrencyWidget extends StatelessWidget {
  const CurrencyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        if (state is CurrencyLoaded) {
          return GestureDetector(
            onTap: () => _showUpdateDialog(context, state.currency.rate),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 1),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                      ),
                    ),
                    child: Icon(
                      Icons.currency_exchange_rounded,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 18),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 1),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currency.rate.toStringAsFixed(0),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              14 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'SYP'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize:
                              10 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CurrencyUpdating) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 24),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                  ),
                  child: SizedBox(
                    width: ResponsiveUtils.getResponsiveIconSize(context, 18),
                    height: ResponsiveUtils.getResponsiveIconSize(context, 18),
                    child: CircularProgressIndicator(
                      strokeWidth:
                          ResponsiveUtils.isTablet(context) ? 3.0 : 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 8),
                ),
                Text(
                  'Updating...'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize:
                        12 * ResponsiveUtils.getFontSizeMultiplier(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CurrencyError) {
          return GestureDetector(
            onTap: () => context.read<CurrencyCubit>().getCurrency(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 6),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.3),
                    Colors.red.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 20),
                ),
                border: Border.all(
                  color: Colors.red.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 4),
                  ),
                  Text(
                    'Retry'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          11 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CurrencyLoading) {
          return Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20),
              ),
            ),
            child: SizedBox(
              width: ResponsiveUtils.getResponsiveIconSize(context, 20),
              height: ResponsiveUtils.getResponsiveIconSize(context, 20),
              child: CircularProgressIndicator(
                strokeWidth: ResponsiveUtils.isTablet(context) ? 3.0 : 2.5,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showUpdateDialog(BuildContext context, double currentRate) {
    final TextEditingController controller = TextEditingController(
      text: currentRate.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 24),
              ),
            ),
            child: Container(
              width: ResponsiveUtils.getResponsiveDialogWidth(context),
              padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
                top: ResponsiveUtils.getResponsiveSpacing(context, 32),
                bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      32,
                    ),
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 20),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, 20),
                      ),
                    ),
                    child: Icon(
                      Icons.currency_exchange_rounded,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24),
                  ),

                  // Title
                  Text(
                    'Update Exchange Rate'.tr(),
                    style: TextStyle(
                      fontSize:
                          24 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),

                  // Subtitle
                  Text(
                    'Set the current USD to SYP exchange rate'.tr(),
                    style: TextStyle(
                      fontSize:
                          16 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 32),
                  ),

                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, 16),
                      ),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize:
                            18 * ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Exchange Rate'.tr(),
                        labelStyle: TextStyle(
                          fontSize:
                              14 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        suffixText: 'SYP'.tr(),
                        suffixStyle: TextStyle(
                          fontSize:
                              16 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF8A95),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            20,
                          ),
                          vertical: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),

                  // Helper text
                  Text(
                    '${'Current rate: '.tr()}${currentRate.toStringAsFixed(0)}${' SYP'.tr()}',
                    style: TextStyle(
                      fontSize:
                          14 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 36),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: Container(
                          height: ResponsiveUtils.getResponsiveButtonHeight(
                            context,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(
                                context,
                                16,
                              ),
                            ),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF64748B),
                              padding:
                                  ResponsiveUtils.getResponsiveButtonPadding(
                                    context,
                                  ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.getResponsiveBorderRadius(
                                    context,
                                    16,
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel'.tr(),
                              style: TextStyle(
                                fontSize:
                                    16 *
                                    ResponsiveUtils.getFontSizeMultiplier(
                                      context,
                                    ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          16,
                        ),
                      ),

                      // Update button
                      Expanded(
                        child: Container(
                          height: ResponsiveUtils.getResponsiveButtonHeight(
                            context,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(
                                context,
                                16,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8A95).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              final newRate = double.tryParse(controller.text);
                              if (newRate != null && newRate > 0) {
                                context
                                    .read<CurrencyCubit>()
                                    .updateCurrencyRate(newRate);
                                Navigator.of(dialogContext).pop();
                              } else {
                                // Show error feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                          size:
                                              ResponsiveUtils.getResponsiveIconSize(
                                                context,
                                                20,
                                              ),
                                        ),
                                        SizedBox(
                                          width:
                                              ResponsiveUtils.getResponsiveSpacing(
                                                context,
                                                12,
                                              ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Please enter a valid exchange rate'
                                                .tr(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding:
                                  ResponsiveUtils.getResponsiveButtonPadding(
                                    context,
                                  ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.getResponsiveBorderRadius(
                                    context,
                                    16,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: ResponsiveUtils.getResponsiveIconSize(
                                    context,
                                    20,
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    8,
                                  ),
                                ),
                                Text(
                                  'Update '.tr(),
                                  style: TextStyle(
                                    fontSize:
                                        16 *
                                        ResponsiveUtils.getFontSizeMultiplier(
                                          context,
                                        ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
