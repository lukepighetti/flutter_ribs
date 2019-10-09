import 'package:ribs/ribs.dart';

import 'logged_in_interactor.dart';
import 'logged_in_router.dart';
import 'logged_in_view_controller.dart';

abstract class LoggedInDependency implements Dependency {
  // Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

class LoggedInComponent extends Component<LoggedInDependency> {
  LoggedInComponent(LoggedInDependency dependency, this.player1Name, this.player2Name) : super(dependency);
  // Declare 'fileprivate' dependencies that are only used by this RIB.
  final String player1Name, player2Name;
}

abstract class LoggedInBuildable implements Buildable {
  LoggedInRouting build(LoggedInListener listener, String player1Name, String player2Name);
}

class LoggedInBuilder extends Builder<LoggedInDependency> implements LoggedInBuildable {
  LoggedInBuilder(LoggedInDependency dependency) : super(dependency);

  @override
  LoggedInRouting build(LoggedInListener listener, String player1Name, String player2Name) {
    final _ = LoggedInComponent(dependency, player1Name, player2Name);
    final viewController = LoggedInViewController(player1Name, player2Name);
    final interactor = LoggedInInteractor(viewController);
    interactor.listener = listener;

    return LoggedInRouter(interactor, viewController);
  }
}
