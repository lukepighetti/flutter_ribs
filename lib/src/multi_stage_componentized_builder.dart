import 'builder.dart';

class MultiStageComponentizedBuilder<Component, Router, DynamicBuildDependency> extends Buildable {
  Component get componentForCurrentBuildPass {
    if (_currentPassComponentIsDirty == false) {
      return _currentPassComponent;
    } else {
      final currentPassComponent = componentBuilder();
      final newComponent = componentBuilder();

      if (_lastComponent == newComponent) {
        assert(false, "$this componentBuilder should produce new instances of component when build is invoked.");
      }

      _lastComponent = newComponent;

      this._currentPassComponent = currentPassComponent;
      _currentPassComponentIsDirty = false;

      return currentPassComponent;
    }
  }

  MultiStageComponentizedBuilder(this.componentBuilder);

  bool _currentPassComponentIsDirty = true;

  Router finalStageBuildWithDynamicDependency(DynamicBuildDependency dynamicDependency) {
    final router = finalStageBuildWithComponent(componentForCurrentBuildPass, dynamicDependency);

    _currentPassComponentIsDirty = true;

    return router;
  }

  Router finalStageBuildWithComponent(Component component, DynamicBuildDependency dynamicDependency) {
    throw UnsupportedError("This method should be overridden by the subclass.");
  }

  Component _currentPassComponent;
  final Component Function() componentBuilder;
  dynamic _lastComponent;
}

class SimpleMultiStageComponentizedBuilder<Component, Router>
    extends MultiStageComponentizedBuilder<Component, Router, void> {
  SimpleMultiStageComponentizedBuilder(Component Function() componentBuilder) : super(componentBuilder);

  @override
  Router finalStageBuildWithComponent(Component component, void _) {
    throw UnsupportedError("This method should be overridden by the subclass.");
  }

  Router finalStageBuild() {
    return finalStageBuildWithDynamicDependency(null);
  }
}
