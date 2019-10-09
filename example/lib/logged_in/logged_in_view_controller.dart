import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'logged_in_interactor.dart';
import 'logged_in_router.dart';

abstract class LoggedInPresentableListener {}

/// The `ribs` architecture sets the listener after the class is created.
/// This violates the @immutable warning from StatelessWidget which expects all properties to be final.
/// But in practice it does not cause any known issues.
class LoggedInViewController extends StatelessWidget with LoggedInViewControllable implements LoggedInPresentable {
  @override
  LoggedInPresentableListener listener;

  @override
  Widget get uiviewController => this;

  _handleLogin() {}

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("LoggedIn"),
      ),
    );
  }
}
