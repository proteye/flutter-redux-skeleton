import 'package:flutter_redux_skeleton/src/store/auth/auth_reducer.dart';
import 'package:flutter_redux_skeleton/src/store/snackbar/snackbar_reducer.dart';
import 'package:flutter_redux_skeleton/src/store/ticket/ticket_reducer.dart';
import 'app_state.dart';

AppState appStateReducer(AppState state, dynamic action) => AppState(
      authState: authStateReducer(state.authState, action),
      snackbarState: snackbarStateReducer(state.snackbarState, action),
      ticketState: ticketStateReducer(state.ticketState, action),
    );
