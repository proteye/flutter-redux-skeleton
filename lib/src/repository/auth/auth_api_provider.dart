import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:flutter_redux_skeleton/src/models/auth_response.dart';
import 'package:flutter_redux_skeleton/src/models/user_response.dart';
import 'package:flutter_redux_skeleton/src/repository/base_api_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/url_provider.dart';
import 'package:flutter_redux_skeleton/src/utils/app_errors.dart';

class AuthApiProvider extends BaseApiProvider {
  Future<AuthResponse> login({
    @required String login,
    @required String password,
    String fields,
  }) async {
    if (login == null || login.trim().isEmpty) {
      return AuthResponse.withError(ValidationError.loginEmpty);
    }
    if (password == null || password.isEmpty) {
      return AuthResponse.withError(ValidationError.passwordEmpty);
    }

    try {
      final response = await dio.post(
        UrlProvider.sign,
        data: {'login': login, 'password': password},
        queryParameters: {'fields': fields},
      );
      return AuthResponse.fromJson(response.data['result']);
    } on DioError catch (e) {
      if (e.response?.statusCode == 400) {
        return AuthResponse.withError(AuthError.loginFailed);
      }
      return AuthResponse.withError(errorHandler(e));
    }
  }

  Future<AuthResponse> logout() async {
    try {
      await dio.delete(
        UrlProvider.sign,
      );
      return AuthResponse(null, null, null);
    } on DioError catch (e) {
      return AuthResponse.withError(errorHandler(e));
    }
  }

  Future<UserResponse> profile({String fields}) async {
    try {
      final response = await dio.get(
        UrlProvider.profile,
        queryParameters: {'fields': fields},
      );
      return UserResponse.fromJson(response.data['result']);
    } on DioError catch (e) {
      return UserResponse.withError(errorHandler(e));
    }
  }
}
