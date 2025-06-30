import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../../../core/network/service_locator.dart';
import '../../domain/usecase/update_syrian_price_use_case.dart';
import '../../domain/entities/product.dart';

class SyrianPriceAdminWidget extends StatefulWidget {
  final Product product;
  final VoidCallback? onPriceUpdated;

  const SyrianPriceAdminWidget({
    super.key,
    required this.product,
    this.onPriceUpdated,
  });

  @override
  State<SyrianPriceAdminWidget> createState() => _SyrianPriceAdminWidgetState();
}

class _SyrianPriceAdminWidgetState extends State<SyrianPriceAdminWidget> {
  bool _isUpdating = false;

  void _showUpdateSyrianPriceDialog() {
    final TextEditingController controller = TextEditingController(
      text:
          widget.product.syrianPoundPrice.isNotEmpty &&
                  widget.product.syrianPoundPrice != '0'
              ? widget.product.syrianPoundPrice
              : '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20),
              ),
            ),
            contentPadding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 24),
            ),
            content: SizedBox(
              width: ResponsiveUtils.getResponsiveDialogWidth(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Update Syrian Price'.tr(),
                    style: TextStyle(
                      fontSize:
                          20 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),

                  // Product name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize:
                          16 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24),
                  ),

                  // Current USD price
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        16,
                      ),
                      vertical: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        12,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                      ),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'USD Price: ',
                          style: TextStyle(
                            fontSize:
                                14 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${widget.product.price}',
                          style: TextStyle(
                            fontSize:
                                16 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                            color: const Color(0xFFFF8A95),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 20),
                  ),

                  // Syrian price input field
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
                        labelText: 'Syrian Price'.tr(),
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
                          color: const Color(0xFF059669),
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
                    'This price will be cached and shown to all users'.tr(),
                    style: TextStyle(
                      fontSize:
                          12 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 32),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                16,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveBorderRadius(
                                  context,
                                  12,
                                ),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 2,
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
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          12,
                        ),
                      ),

                      // Update button
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isUpdating
                                  ? null
                                  : () => _updateSyrianPrice(
                                    controller.text.trim(),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                16,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getResponsiveBorderRadius(
                                  context,
                                  12,
                                ),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isUpdating
                                  ? SizedBox(
                                    width:
                                        ResponsiveUtils.getResponsiveIconSize(
                                          context,
                                          20,
                                        ),
                                    height:
                                        ResponsiveUtils.getResponsiveIconSize(
                                          context,
                                          20,
                                        ),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'Update'.tr(),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _updateSyrianPrice(String newPrice) async {
    if (newPrice.isEmpty) {
      _showErrorMessage('Please enter a valid Syrian price'.tr());
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final updateSyrianPriceUseCase = sl<UpdateSyrianPriceUseCase>();
      final result = await updateSyrianPriceUseCase(
        widget.product.id,
        newPrice,
      );

      result.fold(
        (failure) {
          _showErrorMessage(
            'Failed to update Syrian price. Please try again.'.tr(),
          );
        },
        (updatedProduct) {
          Navigator.of(context).pop();
          _showSuccessMessage('Syrian price updated successfully!'.tr());
          widget.onPriceUpdated?.call();
        },
      );
    } catch (e) {
      _showErrorMessage('An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showUpdateSyrianPriceDialog,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 20),
          ),
          border: Border.all(
            color: const Color(0xFF059669).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: ResponsiveUtils.getResponsiveIconSize(context, 16),
              color: const Color(0xFF059669),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Text(
              'Edit SYP'.tr(),
              style: TextStyle(
                fontSize: 12 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
