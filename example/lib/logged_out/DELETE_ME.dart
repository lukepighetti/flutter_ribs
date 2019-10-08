import 'package:flutter/widgets.dart';
import 'package:ribs/ribs.dart';

/// These are stand in files meant only to silence static analysis before we implement LoggedOut rib

abstract class LoggedOutDependency {}

abstract class LoggedOutListener {}

abstract class LoggedOutBuildable {
  ViewableRouting build(LoggedOutListener listener);
}

class LoggedOutInteractor extends Interactor {}

class LoggedOutViewController extends StatelessWidget with ViewControllable {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("LoggedOutViewController"),
    );
  }
}

class LoggedOutBuilder implements LoggedOutBuildable {
  LoggedOutBuilder(LoggedOutDependency dependency);

  @override
  ViewableRouting build(LoggedOutListener listener) {
    return ViewableRouter<Interactable, ViewControllable>(LoggedOutInteractor(), LoggedOutViewController());
  }
}
