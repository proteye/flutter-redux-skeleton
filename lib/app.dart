import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';

import 'package:flutter_redux_skeleton/src/repository/auth/repository.dart';
import 'package:flutter_redux_skeleton/src/repository/ticket/ticket_api_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/ticket/repository.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/utils/app_router.dart';

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
          title: 'Flutter Redux Skeleton',
          theme: ThemeData(),
          initialRoute: AppRouter.homeRoute,
          routes: AppRouter.routes(),
        ),
      ),
    );
  }
}
