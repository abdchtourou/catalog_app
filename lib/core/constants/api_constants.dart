class ApiConstants {
  // static const String baseUrl = 'http://10.0.2.2:5041/api';
  static const String baseUrl = 'https://alternative-medicine-web-api-production.up.railway.app/api';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  // static const String baseImageUrl = 'http://10.0.2.2:5041/';
  static const String baseImageUrl = 'https://alternative-medicine-web-api-production.up.railway.app/';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Endpoints
  static const String categoriesEndpoint = '/Categories';
  static const String productsEndpoint = '/products';
  static const String attachmentsEndpoint = '/attachments';
  static const String currenciesEndpoint = '/Currencies';

  // Currency endpoints
  static String getCurrenciesEndpoint() => currenciesEndpoint;
  static String updateCurrencyRateEndpoint({required double rate}) =>
      '$currenciesEndpoint?rate=$rate';

  // Category endpoints
  static String getCategoriesEndpoint({
    int pageNumber = 1,
    int pageSize = 10,
  }) => '$categoriesEndpoint?pageNumber=$pageNumber&pageSize=$pageSize';

  static String getCategoryEndpoint(int id) => '$categoriesEndpoint/$id';
  static String deleteCategoryEndpoint(int id) => '$categoriesEndpoint/$id';
  static String updateCategoryEndpoint(int id) => '$categoriesEndpoint/$id';

  // Product endpoints
  static String getProductsByCategory(String categoryId) =>
      '$categoriesEndpoint/$categoryId/products';

  static String getProductsByCategoryWithSearch(
    String categoryId, {
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
  }) {
    String endpoint =
        '$categoriesEndpoint/$categoryId/products?pageNumber=$pageNumber&pageSize=$pageSize';
    if (searchQuery != null && searchQuery.isNotEmpty) {
      endpoint += '&searchQuery=$searchQuery';
    }
    return endpoint;
  }

  static String getProductEndpoint(int id) => '$productsEndpoint/$id';
  static String deleteProductEndpoint(int id) => '$productsEndpoint/$id';
  static String updateProductEndpoint(int id) => '$productsEndpoint/$id';
  static String updateProductWithAttachmentsEndpoint() =>
      '$productsEndpoint/UpdateWithAttachments';

  // Attachment endpoints
  static String getAttachmentEndpoint(int id) => '$attachmentsEndpoint/$id';
  static String deleteAttachmentEndpoint(int id) => '$attachmentsEndpoint/$id';
  static String deleteAttachmentsEndpoint() => attachmentsEndpoint;

  // Pagination
  static const int defaultPageSize = 10;
  static const int defaultPageNumber = 1;
}
