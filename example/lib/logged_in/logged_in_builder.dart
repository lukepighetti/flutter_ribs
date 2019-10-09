import 'package:ribs/ribs.dart';

import 'logged_in_interactor.dart';
import 'logged_in_router.dart';
import 'logged_in_view_controller.dart';

abstract class LoggedInDependency implements Dependency {
  // Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

class LoggedInComponent extends Component<LoggedInDependency> {
  LoggedInComponent(LoggedInDependency dependency) : super(dependency);
  // Declare 'fileprivate' dependencies that are only used by this RIB.
}

abstract class LoggedInBuildable implements Buildable {
  LoggedInRouting build(LoggedInListener listener);
}

class LoggedInBuilder extends Builder<LoggedInDependency> implements LoggedInBuildable {
  LoggedInBuilder(LoggedInDependency dependency) : super(dependency);

  @override
  LoggedInRouting build(LoggedInListener listener) {
    final _ = LoggedInComponent(dependency);
    final viewController = LoggedInViewController();
    final interactor = LoggedInInteractor(viewController);
    interactor.listener = listener;

    return LoggedInRouter(interactor, viewController);
  }
}
