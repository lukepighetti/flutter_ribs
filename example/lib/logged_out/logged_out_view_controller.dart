import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'logged_out_interactor.dart';
import 'logged_out_router.dart';

abstract class LoggedOutPresentableListener {
  void login({String player1Name, String player2Name});
}

class LoggedOutViewController extends StatelessWidget with LoggedOutViewControllable implements LoggedOutPresentable {
  @override
  LoggedOutPresentableListener listener;

  @override
  Widget get uiviewController => this;

  _handleLogin() {
    listener.login(
      player1Name: "Player 1",
      player2Name: "Player 2",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: _handleLogin,
        child: Text("Login"),
      ),
    );
  }
}
