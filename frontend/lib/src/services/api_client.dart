import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../utils/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  late final List<String> _baseUrlCandidates;
  int _baseUrlIndex = 0;
  final StorageService _storageService = StorageService();

  Dio get dio => _dio;

  void init() {
    _baseUrlCandidates = ApiConfig.baseUrlCandidates;
    _baseUrlIndex = 0;

    _dio = Dio(
      BaseOptions(
        baseUrl: _currentBaseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
        headers: ApiConfig.defaultHeaders,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(_createInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }

  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to requests, except for login and register
        final isAuthPath =
            options.path == ApiConfig.login ||
            options.path == ApiConfig.register;

        if (!isAuthPath) {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Token $token';
          }
        } else {
          // Explicitly remove it if it was added by default options
          options.headers.remove('Authorization');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (_shouldRetryWithNextBaseUrl(error) && _moveToNextBaseUrl()) {
          try {
            final requestOptions = error.requestOptions;
            requestOptions.baseUrl = _currentBaseUrl;
            final response = await _dio.fetch(requestOptions);
            handler.resolve(response);
            return;
          } on DioException catch (retryError) {
            error = retryError;
          }
        }

        // Handle token expiration
        if (error.response?.statusCode == 401) {
          await _storageService.clearAll();
          // You can add navigation to login screen here if needed
        }
        handler.next(error);
      },
    );
  }

  String get _currentBaseUrl => _baseUrlCandidates[_baseUrlIndex];

  bool _moveToNextBaseUrl() {
    if (_baseUrlIndex >= _baseUrlCandidates.length - 1) {
      return false;
    }
    _baseUrlIndex += 1;
    _dio.options.baseUrl = _currentBaseUrl;
    if (kDebugMode) {
      debugPrint('ApiClient switched baseUrl to $_currentBaseUrl');
    }
    return true;
  }

  bool _shouldRetryWithNextBaseUrl(DioException error) {
    final type = error.type;
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout;
  }

  // Generic GET request
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
    } catch (e) {
      rethrow;
    }
  }

  // Generic POST request
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
    } catch (e) {
      rethrow;
    }
  }

  // Generic PUT request
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
    } catch (e) {
      rethrow;
    }
  }

  // Generic PATCH request
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
    } catch (e) {
      rethrow;
    }
  }

  // Generic DELETE request
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
    } catch (e) {
      rethrow;
    }
  }
}
