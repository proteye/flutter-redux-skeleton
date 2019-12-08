import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/store/auth/store.dart';
import 'package:flutter_redux_skeleton/src/ui/screens/home_screen.dart';
import 'package:flutter_redux_skeleton/src/ui/screens/login_screen.dart';
import 'package:flutter_redux_skeleton/src/ui/screens/detail_screen.dart';

class AppRouter {
  static final String homeRoute = '/';
  static final String loginRoute = '/login';
  static final String detailRoute = '/detail';

  static Map<String, WidgetBuilder> routes() {
    return {
      homeRoute: (context) {
        return StoreConnector<AppState, AuthState>(
          converter: (store) => store.state.authState,
          builder: (_, authState) {
            if (authState.hasToken) {
              return HomeScreen();
            }
            return LoginScreen();
          },
        );
      },
      loginRoute: (context) => LoginScreen(),
      detailRoute: (context) => DetailScreen(),
    };
  }
}
