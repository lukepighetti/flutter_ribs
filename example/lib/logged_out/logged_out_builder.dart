import 'package:ribs/ribs.dart';

import 'logged_out_interactor.dart';
import 'logged_out_router.dart';
import 'logged_out_view_controller.dart';

abstract class LoggedOutDependency implements Dependency {
  // Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

class LoggedOutComponent extends Component<LoggedOutDependency> {
  LoggedOutComponent(LoggedOutDependency dependency) : super(dependency);
  // Declare 'fileprivate' dependencies that are only used by this RIB.
}

abstract class LoggedOutBuildable implements Buildable {
  LoggedOutRouting build(LoggedOutListener listener);
}

class LoggedOutBuilder extends Builder<LoggedOutDependency> implements LoggedOutBuildable {
  LoggedOutBuilder(LoggedOutDependency dependency) : super(dependency);

  @override
  LoggedOutRouting build(LoggedOutListener listener) {
    final _ = LoggedOutComponent(dependency);
    final viewController = LoggedOutViewController();
    final interactor = LoggedOutInteractor(viewController);
    interactor.listener = listener;

    return LoggedOutRouter(interactor, viewController);
  }
}
