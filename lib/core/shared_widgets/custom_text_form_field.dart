import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final VoidCallback? onTap;
  final bool readOnly;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText.tr(),
        hintText: hintText?.tr(),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

// Predefined validators for common use cases
class FormValidators {
  static String? Function(String?) required(String fieldName) {
    return (value) => value == null || value.isEmpty
        ? 'Please enter a $fieldName'.tr()
        : null;
  }

  static String? Function(String?) email() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter an email'.tr();
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'Please enter a valid email'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) minLength(int minLength) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required'.tr();
      }
      if (value.length < minLength) {
        return 'Must be at least $minLength characters'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(int maxLength) {
    return (value) {
      if (value != null && value.length > maxLength) {
        return 'Must be at most $maxLength characters'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) price() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a price'.tr();
      }
      final price = double.tryParse(value);
      if (price == null || price < 0) {
        return 'Please enter a valid price'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) positiveNumber() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required'.tr();
      }
      final number = double.tryParse(value);
      if (number == null || number <= 0) {
        return 'Please enter a positive number'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) phoneNumber() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a phone number'.tr();
      }
      if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
        return 'Please enter a valid phone number'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) url() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a URL'.tr();
      }
      if (!RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$').hasMatch(value)) {
        return 'Please enter a valid URL'.tr();
      }
      return null;
    };
  }

  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
