import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;
  final EdgeInsetsGeometry? padding;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size ?? 40,
              height: size ?? 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (showMessage) ...[
              const SizedBox(height: 16),
              Text(
                message?.tr() ?? 'Loading...'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingStateVariants {
  static Widget small({String? message, EdgeInsetsGeometry? padding}) {
    return LoadingStateWidget(
      size: 24,
      message: message,
      showMessage: message != null,
      padding: padding,
    );
  }

  static Widget medium({String? message, EdgeInsetsGeometry? padding}) {
    return LoadingStateWidget(
      size: 32,
      message: message,
      padding: padding,
    );
  }

  static Widget large({String? message, EdgeInsetsGeometry? padding}) {
    return LoadingStateWidget(
      size: 48,
      message: message,
      padding: padding,
    );
  }

  static Widget fullScreen({String? message}) {
    return Scaffold(
      body: LoadingStateWidget(
        size: 60,
        message: message,
      ),
    );
  }

  static Widget overlay({String? message}) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: LoadingStateWidget(
        size: 50,
        message: message,
        color: Colors.white,
      ),
    );
  }

  static Widget inline({String? message}) {
    return LoadingStateWidget(
      size: 20,
      message: message,
      showMessage: false,
      padding: const EdgeInsets.all(8.0),
    );
  }

  static Widget card({String? message}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LoadingStateWidget(
          size: 40,
          message: message,
        ),
      ),
    );
  }

  static Widget list({String? message}) {
    return SliverToBoxAdapter(
      child: LoadingStateWidget(
        size: 36,
        message: message,
        padding: const EdgeInsets.symmetric(vertical: 32.0),
      ),
    );
  }
}
