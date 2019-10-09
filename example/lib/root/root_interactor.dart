import 'package:ribs/ribs.dart';

import 'root_router.dart';
import 'root_view_controller.dart';

abstract class RootRouting implements ViewableRouting {
  // Declare methods the interactor can invoke to manage sub-tree via the router.
  routeToLoggedIn(String player1Name, String player2Name);
}

abstract class RootPresentable implements Presentable {
  RootPresentableListener listener;
  // Declare methods the interactor can invoke the presenter to present data.
}

abstract class RootListener {
  // Declare methods the interactor can invoke to communicate with other RIBs.
}

class RootInteractor extends PresentableInteractor<RootPresentable>
    implements RootInteractable, RootPresentableListener {
  // Do not perform any logic in constructor.
  RootInteractor(RootPresentable presenter) : super(presenter) {
    presenter.listener = this;
  }

  RootRouting router;
  RootListener listener;

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

  @override
  void didLogin(String player1Name, String player2Name) {
    if (player1Name.isNotEmpty && player2Name.isNotEmpty) {
      router.routeToLoggedIn(player1Name, player2Name);
    }
  }
}
