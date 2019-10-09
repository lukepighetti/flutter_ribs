import 'package:ribs/ribs.dart';

import '../root/root_builder.dart';

/// The top level component with no dependencies
class AppComponent extends Component<EmptyDependency> implements RootDependency {
  AppComponent() : super(EmptyComponent());
}
