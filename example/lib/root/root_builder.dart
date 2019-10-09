import 'package:ribs/ribs.dart';

import 'root_component.dart';
import 'root_interactor.dart';
import 'root_router.dart';
import 'root_view_controller.dart';

import '../logged_out/logged_out_builder.dart';

abstract class RootDependency implements Dependency {
  // Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

class RootComponent extends Component<RootDependency> with RootChildrenDependencies {
  RootComponent(RootDependency dependency, this.viewController) : super(dependency);
  final RootViewController viewController;
  // Declare dependencies that are only used by this RIB.
}

abstract class RootBuildable extends Buildable {
  LaunchRouting build();
}

class RootBuilder extends Builder<RootDependency> implements RootBuildable {
  RootBuilder(RootDependency dependency) : super(dependency);

  @override
  LaunchRouting build() {
    final viewController = RootViewController();
    final component = RootComponent(dependency, viewController);
    final interactor = RootInteractor(viewController);

    final loggedOutBuilder = LoggedOutBuilder(component);
    return RootRouter(interactor, viewController, loggedOutBuilder);
  }
}
