import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_redux_skeleton/src/repository/auth/auth_api_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/auth/auth_storage_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/auth/repository.dart';
import 'package:flutter_redux_skeleton/src/repository/ticket/ticket_api_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/ticket/repository.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_reducer.dart';
import 'package:flutter_redux_skeleton/src/store/auth/store.dart';
import 'package:flutter_redux_skeleton/src/utils/app_logger.dart';
import 'package:flutter_redux_skeleton/src/utils/app_router.dart';
import 'package:flutter_redux_skeleton/src/utils/http.dart';

void main() {
  AppLogger()..isDebug = true;

  final store = Store<AppState>(
    appStateReducer,
    initialState: AppState.initial(),
    middleware: [thunkMiddleware, LoggingMiddleware.printer()],
  );

  SharedPreferences.getInstance().then((prefs) {
    // init dio params and headers
    Http()..init(store, prefs);
    // init auth repository
    final authRepository = AuthRepository(
      AuthStorageProvider(prefs),
      AuthApiProvider(),
    );
    // remind user session
    store.dispatch(remind(authRepository));

    runApp(App(store: store, authRepository: authRepository));
  });
}

class App extends StatefulWidget {
  final Store store;
  final AuthRepository authRepository;

  const App({Key key, this.store, this.authRepository}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription storeSubscription;
  bool snackbarShow = false;

  @override
  void initState() {
    super.initState();
    storeSubscription = widget.store.onChange.listen((state) {
      // Listening snackbar state to show/hide a SnackBar
      final snackbarState = state.snackbarState;
      if (!snackbarState.show &&
          snackbarShow &&
          snackbarState.context != null) {
        // HIDE SNACKBAR
        snackbarShow = false;
        Scaffold.of(snackbarState.context).hideCurrentSnackBar();
      } else if (snackbarState.show &&
          !snackbarShow &&
          snackbarState.context != null) {
        // SHOW SNACKBAR
        snackbarShow = true;
        Scaffold.of(snackbarState.context)
            .showSnackBar(snackbarState.snackBar)
            .closed
            .then((SnackBarClosedReason reason) {
          if (reason != SnackBarClosedReason.action &&
              snackbarState.callback != null) {
            snackbarState.callback();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    storeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketRepository = TicketRepository(
      TicketApiProvider(),
    );

    return StoreProvider<AppState>(
      store: widget.store,
      child: MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: widget.authRepository),
          Provider<TicketRepository>.value(value: ticketRepository),
        ],
        child: MaterialApp(
          title: 'Flutter Redux Example',
          theme: ThemeData(),
          initialRoute: AppRouter.homeRoute,
          routes: AppRouter.routes(),
        ),
      ),
    );
  }
}
