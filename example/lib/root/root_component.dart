import 'package:ribs/ribs.dart';

import '../logged_out/logged_out_builder.dart';
import '../logged_in/logged_in_builder.dart';

/// The dependencies needed from the parent scope of Root to provide for the LoggedOut scope.
abstract class RootDependencyLoggedOut implements Dependency {
// TODO: Update RootDependency protocol to inherit this protocol.
}

mixin RootChildrenDependencies implements LoggedOutDependency, LoggedInDependency {
  // TODO: Implement properties to provide for LoggedOut scope.
}
