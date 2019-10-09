import 'package:ribs/ribs.dart';

import 'logged_out_interactor.dart';

abstract class LoggedOutInteractable implements Interactable {
  LoggedOutRouting router;
  LoggedOutListener listener;
}

abstract class LoggedOutViewControllable implements ViewControllable {
  // Declare methods the router invokes to manipulate the view hierarchy.
}

class LoggedOutRouter extends ViewableRouter<LoggedOutInteractable, LoggedOutViewControllable>
    implements LoggedOutRouting {
  LoggedOutRouter(LoggedOutInteractable interactor, LoggedOutViewControllable viewController)
      : super(interactor, viewController) {
    interactor.router = this;
  }
}
