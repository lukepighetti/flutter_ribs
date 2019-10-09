import 'package:ribs/ribs.dart';

import 'logged_in_interactor.dart';

abstract class LoggedInInteractable implements Interactable {
  LoggedInRouting router;
  LoggedInListener listener;
}

abstract class LoggedInViewControllable implements ViewControllable {
  // Declare methods the router invokes to manipulate the view hierarchy.
}

class LoggedInRouter extends ViewableRouter<LoggedInInteractable, LoggedInViewControllable> implements LoggedInRouting {
  LoggedInRouter(LoggedInInteractable interactor, LoggedInViewControllable viewController)
      : super(interactor, viewController) {
    interactor.router = this;
  }
}
