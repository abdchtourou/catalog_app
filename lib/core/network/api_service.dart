import 'package:catalog_app/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'network_info.dart';

class ApiService {
  late final Dio _dio;
  final NetworkInfo networkInfo;
  static const String baseUrl =
      ApiConstants.baseUrl; // Replace with your API base URL
  static const int connectTimeout = ApiConstants.connectTimeout; // 30 seconds
  static const int receiveTimeout = ApiConstants.receiveTimeout; // 30 seconds

  ApiService({required this.networkInfo}) {
    _dio = Dio();

    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      headers: ApiConstants.defaultHeaders,
    );

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check network connectivity before making request
          if (!await networkInfo.isConnected) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'No internet connection',
              ),
            );
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw ApiException('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        throw ApiException(_getErrorMessage(error.response?.statusCode));
      case DioExceptionType.cancel:
        throw ApiException('Request was cancelled');
      case DioExceptionType.connectionError:
        throw ApiException('No internet connection');
      default:
        throw ApiException('Something went wrong. Please try again.');
    }
  }

  String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized access';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Something went wrong';
    }
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
        if (data != null) ...data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Upload multiple files
  Future<Response<T>> uploadMultipleFiles<T>(
    String path,
    List<String> filePaths, {
    List<String>? fileNames,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {};

      // Add multiple files
      for (int i = 0; i < filePaths.length; i++) {
        final fileName = fileNames != null && i < fileNames.length
            ? fileNames[i]
            : null;
        formDataMap['Images'] = await MultipartFile.fromFile(
          filePaths[i],
          filename: fileName,
        );
      }

      // Add other data
      if (data != null) {
        formDataMap.addAll(data);
      }

      final formData = FormData.fromMap(formDataMap);

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Upload file
  Future<Response<T>> updateUploadedFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
        if (data != null) ...data,
      });

      return await _dio.put<T>(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Cancel all requests
  void cancelRequests() {
    _dio.close();
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}
