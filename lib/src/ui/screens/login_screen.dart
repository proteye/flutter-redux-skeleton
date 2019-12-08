import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/ui/widgets/login_form.dart';
import 'package:flutter_redux_skeleton/src/utils/styles.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Form(
        child: Column(
          children: <Widget>[
            SizedBox(height: 75),
            Icon(
              Icons.call_to_action,
              color: Styles.dimGray,
              size: 125,
            ),
            SizedBox(height: 25),
            StoreConnector<AppState, LoginFormViewModel>(
              converter: LoginFormViewModel.fromStore,
              builder: (_, viewModel) {
                return LoginForm(viewModel: viewModel);
              },
            ),
          ],
        ),
      ),
    ));
  }
}
