import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:flutter_redux_skeleton/src/models/user_model.dart';
import 'package:flutter_redux_skeleton/src/repository/auth/repository.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/utils/app_errors.dart';

const USER_FIELDS = '_id,username,email,role,profile(*)';

abstract class AuthAction {
  @override
  String toString() {
    return '$runtimeType';
  }
}

class AuthLoading extends AuthAction {}

class AuthUpdate extends AuthAction {
  final String token;
  final User user;
  final bool isLoading;

  AuthUpdate({this.token, this.user, this.isLoading});
}

class AuthLoggedIn extends AuthAction {
  final String token;
  final User user;

  AuthLoggedIn({@required this.token, this.user}) : assert(token != null);
}

class AuthLoggedOut extends AuthAction {}

class AuthError extends AuthAction {
  final AppBaseError error;

  AuthError({this.error});
}

class AuthClearError extends AuthAction {}

ThunkAction<AppState> remind(AuthRepository authRepository,
    {String fields = USER_FIELDS}) {
  return (Store<AppState> store) async {
    store.dispatch(AuthLoading());

    if (authRepository.hasToken()) {
      final token = authRepository.getToken();
      // check if the token is expired
      final authResponse = await authRepository.profile();
      if (authResponse.error == null) {
        store.dispatch(AuthLoggedIn(token: token, user: authResponse.user));
        return;
      }
    }

    await authRepository.removeToken();
    store.dispatch(AuthLoggedOut());
  };
}

ThunkAction<AppState> signin(
    BuildContext context, String login, String password,
    {String fields = USER_FIELDS}) {
  final authRepository = Provider.of<AuthRepository>(context);
  return (Store<AppState> store) async {
    store.dispatch(AuthLoading());

    final authResponse =
        await authRepository.login(login: login, password: password);

    if (authResponse.error != null) {
      store.dispatch(AuthError(error: authResponse.error));
      return;
    }

    await authRepository.setToken(authResponse.token);

    store.dispatch(
        AuthLoggedIn(token: authResponse.token, user: authResponse.user));
  };
}

ThunkAction<AppState> signout(BuildContext context) {
  final authRepository = Provider.of<AuthRepository>(context);
  return (Store<AppState> store) async {
    store.dispatch(AuthLoading());

    await authRepository.logout();
    await authRepository.removeToken();

    store.dispatch(AuthLoggedOut());
  };
}
