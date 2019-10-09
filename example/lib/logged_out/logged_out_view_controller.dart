import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'logged_out_interactor.dart';
import 'logged_out_router.dart';

abstract class LoggedOutPresentableListener {
  void login({String player1Name, String player2Name});
}

/// The `ribs` architecture sets the listener after the class is created.
/// This violates the @immutable warning from StatelessWidget which expects all properties to be final.
/// But in practice it does not cause any known issues.
class LoggedOutViewController extends StatelessWidget with LoggedOutViewControllable implements LoggedOutPresentable {
  @override
  LoggedOutPresentableListener listener;

  @override
  Widget get uiviewController => this;

  final _defaultPlayer1Name = "Player 1";
  final _defaultPlayer2Name = "Player 2";

  _handleLogin() {
    listener.login(
      player1Name: _player1Controller.text.isEmpty ? _defaultPlayer1Name : _player1Controller.text,
      player2Name: _player2Controller.text.isEmpty ? _defaultPlayer2Name : _player2Controller.text,
    );
  }

  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _player1Controller,
              decoration: InputDecoration(hintText: _defaultPlayer1Name, helperText: "Player 1 name"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _player2Controller,
              decoration: InputDecoration(hintText: _defaultPlayer2Name, helperText: "Player 2 name"),
            ),
            SizedBox(height: 12),
            RaisedButton(
              onPressed: _handleLogin,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
