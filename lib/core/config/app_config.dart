/// Global application configuration
class AppConfig {
  // Admin configuration
  static const bool isAdmin = false; // Set to true for admin access

  // Other global configurations can be added here
  static const String appName = 'Catalog App';
  static const String appVersion = '1.0.0';

  // API configurations
  static const int requestTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Image configurations
  static const int maxImagesPerProduct = 10;
  static const int maxImageSizeMB = 5;

  // UI configurations
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
}
