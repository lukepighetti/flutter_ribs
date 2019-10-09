import 'package:ribs/ribs.dart';

import 'root_interactor.dart';

import '../logged_out/logged_out_builder.dart';
import '../logged_out/logged_out_interactor.dart';
import '../logged_in/logged_in_builder.dart';
import '../logged_in/logged_in_interactor.dart';

abstract class RootInteractable implements Interactable, LoggedOutListener, LoggedInListener {
  RootRouting router;
  RootListener listener;
}

abstract class RootViewControllable implements ViewControllable {
  void present(ViewControllable viewController);
  void dismiss(ViewControllable viewController);
}

class RootRouter extends LaunchRouter<RootInteractable, RootViewControllable> implements RootRouting {
  RootRouter(
      RootInteractable interactor, RootViewControllable viewController, this.loggedOutBuilder, this.loggedInBuilder)
      : super(interactor, viewController) {
    interactor.router = this;
  }

  final LoggedOutBuildable loggedOutBuilder;
  final LoggedInBuildable loggedInBuilder;

  ViewableRouting loggedOut;

  @override
  didLoad() {
    super.didLoad();

    final loggedOut = loggedOutBuilder.build(interactor);
    this.loggedOut = loggedOut;
    attachChild(loggedOut);

    viewController.present(loggedOut.viewControllable);
  }

  @override
  routeToLoggedIn(String player1Name, String player2Name) {
    if (loggedOut != null) {
      detachChild(loggedOut);
      viewController.dismiss(loggedOut.viewControllable);
      loggedOut = null;
    }

    final loggedIn = loggedInBuilder.build(interactor);
    attachChild(loggedIn);

    viewController.present(loggedIn.viewControllable);
  }
}
