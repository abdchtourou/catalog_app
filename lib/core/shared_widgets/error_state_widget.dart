import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryButtonText;
  final bool showRetryButton;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final Color? textColor;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryButtonText,
    this.showRetryButton = true,
    this.padding,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message.tr(),
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText?.tr() ?? 'Try Again'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateVariants {
  static Widget network({VoidCallback? onRetry, EdgeInsetsGeometry? padding}) {
    return ErrorStateWidget(
      message: 'Network error. Please check your connection.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      padding: padding,
    );
  }

  static Widget notFound({VoidCallback? onRetry, EdgeInsetsGeometry? padding}) {
    return ErrorStateWidget(
      message: 'The requested item was not found.',
      icon: Icons.search_off,
      onRetry: onRetry,
      padding: padding,
    );
  }

  static Widget serverError({VoidCallback? onRetry, EdgeInsetsGeometry? padding}) {
    return ErrorStateWidget(
      message: 'Server error. Please try again later.',
      icon: Icons.error_outline,
      onRetry: onRetry,
      padding: padding,
    );
  }

  static Widget unauthorized({VoidCallback? onRetry, EdgeInsetsGeometry? padding}) {
    return ErrorStateWidget(
      message: 'You are not authorized to access this content.',
      icon: Icons.lock_outline,
      onRetry: onRetry,
      showRetryButton: false,
      padding: padding,
    );
  }

  static Widget generic({
    required String message,
    VoidCallback? onRetry,
    EdgeInsetsGeometry? padding,
  }) {
    return ErrorStateWidget(
      message: message,
      onRetry: onRetry,
      padding: padding,
    );
  }

  static Widget card({
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Card(
      child: ErrorStateWidget(
        message: message,
        onRetry: onRetry,
        icon: icon,
        padding: const EdgeInsets.all(24.0),
      ),
    );
  }

  static Widget inline({
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return ErrorStateWidget(
      message: message,
      onRetry: onRetry,
      icon: icon ?? Icons.warning,
      showRetryButton: onRetry != null,
      padding: const EdgeInsets.all(16.0),
      iconColor: Colors.orange,
    );
  }

  static Widget list({
    required String message,
    VoidCallback? onRetry,
  }) {
    return SliverToBoxAdapter(
      child: ErrorStateWidget(
        message: message,
        onRetry: onRetry,
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      ),
    );
  }

  static Widget empty({
    String? message,
    VoidCallback? onRetry,
    String? actionText,
  }) {
    return ErrorStateWidget(
      message: message ?? 'No items found',
      icon: Icons.inbox_outlined,
      onRetry: onRetry,
      retryButtonText: actionText,
      iconColor: Colors.grey.shade400,
      textColor: Colors.grey.shade600,
    );
  }
}
