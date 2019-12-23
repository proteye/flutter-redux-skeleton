import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_redux_skeleton/src/repository/auth/auth_api_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/auth/auth_storage_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/auth/repository.dart';
import 'package:flutter_redux_skeleton/src/repository/url_provider.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_reducer.dart';
import 'package:flutter_redux_skeleton/src/store/auth/store.dart';
import 'package:flutter_redux_skeleton/src/utils/app_config.dart';
import 'package:flutter_redux_skeleton/src/utils/app_logger.dart';
import 'package:flutter_redux_skeleton/src/utils/http.dart';
import './app.dart';

Future mainCommon({
  @required AppFlavor appFlavor,
  @required bool isDebug,
  @required String host,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger()..isDebug = isDebug;
  UrlProvider()..host = host;

  final store = Store<AppState>(
    appStateReducer,
    initialState: AppState.initial(),
    middleware: [thunkMiddleware, LoggingMiddleware.printer()],
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isDebug) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  ErrorWidget.builder = (FlutterErrorDetails error) {
    if (isDebug) {
      FlutterError.dumpErrorToConsole(error);
    } else {
      Zone.current.handleUncaughtError(error.exception, error.stack);
    }

    return Scaffold(body: Container());
  };

  await runZoned<Future<void>>(() async {
    await SharedPreferences.getInstance().then((prefs) {
      // init dio params and headers
      Http()..init(store, prefs);
      // init auth repository
      final authRepository = AuthRepository(
        AuthStorageProvider(prefs),
        AuthApiProvider(),
      );
      // remind user session
      store.dispatch(remind(authRepository));

      runApp(
        AppConfig(
          appFlavor: appFlavor,
          isDebug: isDebug,
          child: App(store: store, authRepository: authRepository),
        ),
      );
    });
  }, onError: (Object error, StackTrace stackTrace) async {
    if (isDebug) {
      debugPrint(stackTrace.toString());
      return;
    }
    // Send to crashlytics, sentry or other
  });
}
