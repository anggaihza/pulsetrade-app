import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pulsetrade_app/core/config/environment.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/network/network_info.dart';
import 'package:pulsetrade_app/core/utils/logger.dart';
import 'package:riverpod/riverpod.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.networkInfo,
    this.retries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
  });

  final Dio dio;
  final NetworkInfo networkInfo;
  final int retries;
  final Duration retryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    for (var attempt = 0; attempt < retries; attempt++) {
      final connected = await networkInfo.isConnected;
      if (!connected) {
        await Future<void>.delayed(retryDelay * (attempt + 1));
        continue;
      }

      try {
        final response = await dio.fetch<dynamic>(err.requestOptions);
        return handler.resolve(response);
      } catch (error, stackTrace) {
        logInfo(
          'Retry attempt ${attempt + 1} failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (attempt == retries - 1) {
          return handler.next(err);
        }
        await Future<void>.delayed(retryDelay * (attempt + 1));
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;
  }
}

Failure mapDioException(DioException exception) {
  final fallbackMessage = exception.message ?? 'Unexpected error';
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure(fallbackMessage, cause: exception);
    case DioExceptionType.badResponse:
      final statusCode = exception.response?.statusCode ?? 0;
      if (statusCode == 401 || statusCode == 403) {
        return AuthFailure('Unauthorized', cause: exception);
      }
      if (statusCode >= 400 && statusCode < 500) {
        return ValidationFailure('Invalid request', cause: exception);
      }
      return NetworkFailure('Server error', cause: exception);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return UnknownFailure(fallbackMessage, cause: exception);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentConfigProvider);
  final options = BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: const <String, String>{'Accept': 'application/json'},
  );

  final dio = Dio(options);
  dio.interceptors.add(
    RetryInterceptor(dio: dio, networkInfo: ref.watch(networkInfoProvider)),
  );
  if (env.enableLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => logInfo(object.toString()),
      ),
    );
  }
  return dio;
});
