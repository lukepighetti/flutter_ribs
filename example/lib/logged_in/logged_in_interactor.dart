import 'package:ribs/ribs.dart';

import 'logged_in_router.dart';
import 'logged_in_view_controller.dart';

abstract class LoggedInRouting implements ViewableRouting {
  // Declare methods the interactor can invoke to manage sub-tree via the router.
}

abstract class LoggedInPresentable implements Presentable {
  LoggedInPresentableListener listener;
  // Declare methods the interactor can invoke the presenter to present data.
}

abstract class LoggedInListener {
  // Declare methods the interactor can invoke to communicate with other RIBs.
}

class LoggedInInteractor extends PresentableInteractor<LoggedInPresentable>
    implements LoggedInInteractable, LoggedInPresentableListener {
  LoggedInInteractor(LoggedInPresentable presenter) : super(presenter) {
    presenter.listener = this;
  }

  LoggedInListener listener;
  LoggedInRouting router;

  @override
  didBecomeActive() {
    super.didBecomeActive();
    // Implement business logic here.
  }

  @override
  willResignActive() {
    super.willResignActive();
    // Pause any business logic.
  }
}
