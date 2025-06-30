import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
        ),
      ),
      elevation: ResponsiveUtils.getResponsiveElevation(context, 8.0),
      child: Container(
        width: ResponsiveUtils.getResponsiveDialogWidth(context),
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon section
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                ),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
                  ),
                ),
                child: Icon(
                  icon!,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 32.0),
                  color: iconColor ?? Colors.red,
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
              ),
            ],

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 28.0),
            ),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: Container(
                    height: ResponsiveUtils.getResponsiveButtonHeight(context),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          12.0,
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFF64748B),
                        padding: ResponsiveUtils.getResponsiveButtonPadding(
                          context,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(
                              context,
                              12.0,
                            ),
                          ),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize:
                              16.0 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),

                // Confirm button
                Expanded(
                  child: Container(
                    height: ResponsiveUtils.getResponsiveButtonHeight(context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          confirmColor ?? const Color(0xFFEF4444),
                          (confirmColor ?? const Color(0xFFEF4444)).withOpacity(
                            0.8,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          12.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (confirmColor ?? const Color(0xFFEF4444))
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: ResponsiveUtils.getResponsiveButtonPadding(
                          context,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(
                              context,
                              12.0,
                            ),
                          ),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontSize:
                              16.0 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog with enhanced tablet support
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ConfirmationDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            onConfirm: onConfirm,
            onCancel: onCancel,
            confirmColor: confirmColor,
            icon: icon,
            iconColor: iconColor,
          ),
    );
  }
}

class ConfirmationDialogVariants {
  static Future<bool?> delete(
    BuildContext context, {
    required String itemName,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context,
      title: 'Delete $itemName',
      message:
          message ??
          'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      icon: Icons.delete_outline,
    );
  }

  static Future<bool?> save(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context,
      title: title ?? 'Save Changes',
      message: message ?? 'Do you want to save your changes?',
      confirmText: 'Save',
      icon: Icons.save_outlined,
    );
  }

  static Future<bool?> discard(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context,
      title: title ?? 'Discard Changes',
      message:
          message ??
          'Are you sure you want to discard your changes? All unsaved changes will be lost.',
      confirmText: 'Discard',
      icon: Icons.close,
    );
  }

  static Future<bool?> logout(BuildContext context, {String? message}) {
    return ConfirmationDialog.show(
      context,
      title: 'Logout',
      message: message ?? 'Are you sure you want to logout?',
      confirmText: 'Logout',
      icon: Icons.logout,
    );
  }

  static Future<bool?> clear(
    BuildContext context, {
    required String itemName,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context,
      title: 'Clear $itemName',
      message: message ?? 'Are you sure you want to clear all $itemName?',
      confirmText: 'Clear',
      icon: Icons.clear_all,
    );
  }

  static Future<bool?> custom(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
  }) {
    return ConfirmationDialog.show(
      context,
      title: title,
      message: message,
      confirmText: confirmText ?? 'Confirm',
      cancelText: cancelText ?? 'Cancel',
      icon: icon,
    );
  }
}
