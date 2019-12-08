import 'package:dio/dio.dart';

import 'package:flutter_redux_skeleton/src/utils/http.dart';
import 'package:flutter_redux_skeleton/src/utils/app_errors.dart';

class BaseApiProvider {
  final Dio dio = Http().dio;

  AppBaseError errorHandler(DioError error) {
    if (error.response?.statusCode == 403) {
      return AuthError.invalidSession;
    }

    return NetworkError.unknown(
        error.response?.statusCode, error.response?.statusMessage, error.error)
      ..report();
  }
}
