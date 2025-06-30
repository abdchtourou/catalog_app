import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FormSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const FormSubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.icon,
    this.enabled = true,
    this.padding,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonEnabled = enabled && !isLoading && onPressed != null;

    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: isButtonEnabled ? 2 : 0,
          shadowColor: theme.primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Predefined button variants for common use cases
class FormSubmitButtonVariants {
  static Widget create({
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: 'Create',
      isLoading: isLoading,
      enabled: enabled,
      icon: Icons.add,
      width: width,
      height: height,
    );
  }

  static Widget update({
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: 'Update',
      isLoading: isLoading,
      enabled: enabled,
      icon: Icons.edit,
      width: width,
      height: height,
    );
  }

  static Widget save({
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: 'Save',
      isLoading: isLoading,
      enabled: enabled,
      icon: Icons.save,
      width: width,
      height: height,
    );
  }

  static Widget delete({
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: 'Delete',
      isLoading: isLoading,
      enabled: enabled,
      backgroundColor: Colors.red,
      icon: Icons.delete,
      width: width,
      height: height,
    );
  }

  static Widget submit({
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool enabled = true,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: 'Submit',
      isLoading: isLoading,
      enabled: enabled,
      icon: Icons.send,
      width: width,
      height: height,
    );
  }

  static Widget cancel({
    required VoidCallback? onPressed,
    bool enabled = true,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: 'Cancel',
      enabled: enabled,
      backgroundColor: Colors.grey,
      icon: Icons.close,
      width: width,
      height: height,
    );
  }

  static Widget primary({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    bool enabled = true,
    IconData? icon,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: text,
      isLoading: isLoading,
      enabled: enabled,
      icon: icon,
      width: width,
      height: height,
    );
  }

  static Widget secondary({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    bool enabled = true,
    IconData? icon,
    double? width,
    double height = 48,
  }) {
    return FormSubmitButton(
      onPressed: onPressed,
      text: text,
      isLoading: isLoading,
      enabled: enabled,
      backgroundColor: Colors.grey.shade600,
      icon: icon,
      width: width,
      height: height,
    );
  }
}
