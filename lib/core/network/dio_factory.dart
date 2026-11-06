import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:good_eating/core/constants/api_constants.dart';

/// Builds the configured [Dio] instance for TheMealDB.
abstract final class DioFactory {
  static Dio create({bool enableLogging = kDebugMode}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: const {'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          responseBody: false,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
    return dio;
  }
}
