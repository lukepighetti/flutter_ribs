import 'package:ribs/ribs.dart';

import 'logged_out_router.dart';
import 'logged_out_view_controller.dart';

abstract class LoggedOutRouting implements ViewableRouting {
  // Declare methods the interactor can invoke to manage sub-tree via the router.
}

abstract class LoggedOutPresentable implements Presentable {
  LoggedOutPresentableListener listener;
  // Declare methods the interactor can invoke the presenter to present data.
}

abstract class LoggedOutListener {
  // Declare methods the interactor can invoke to communicate with other RIBs.
  void didLogin(String player1Name, String player2Name);
}

class LoggedOutInteractor extends PresentableInteractor<LoggedOutPresentable>
    implements LoggedOutInteractable, LoggedOutPresentableListener {
  LoggedOutInteractor(LoggedOutPresentable presenter) : super(presenter) {
    presenter.listener = this;
  }

  LoggedOutListener listener;
  LoggedOutRouting router;

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
  void login({String player1Name, String player2Name}) {
    player1Name ??= "Player 1";
    player2Name ??= "Player 2";

    print("Login with $player1Name, $player2Name");
    listener.didLogin(player1Name, player2Name);
  }
}
