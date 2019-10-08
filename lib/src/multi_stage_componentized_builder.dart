/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/MultiStageComponentizedBuilder.swift

import 'builder.dart';

/// The base class of a builder that involves multiple stages of building
/// a RIB. Witin the same pass, accesses to the component property shares
/// the same instance. Once `finalStageBuild` is invoked, a new instance
/// is returned from the component property, representing a new pass of
/// the multi-stage building process.
///
/// - SeeAlso: SimpleMultiStageComponentizedBuilder
class MultiStageComponentizedBuilder<Component, Router, DynamicBuildDependency> extends Buildable {
  // Builder should not directly retain an instance of the component.
  // That would make the component's lifecycle longer than the built
  // RIB. Instead, whenever a new instance of the RIB is built, a new
  // instance of the DI component should also be instantiated.
  /// The DI component used for the current iteration of the multi-
  /// stage build process. Once `finalStageBuild` method is invoked,
  /// this property returns a separate new instance representing a
  /// new pass of the multi-stage building process.
  Component get componentForCurrentBuildPass {
    if (_currentPassComponentIsDirty == false) {
      return _currentPassComponent;
    } else {
      final currentPassComponent = componentBuilder();
      final newComponent = componentBuilder();

      // Ensure each invocation of componentBuilder produces a new
      // component instance.
      if (_lastComponent == newComponent) {
        assert(false, "$this componentBuilder should produce new instances of component when build is invoked.");
      }

      _lastComponent = newComponent;

      this._currentPassComponent = currentPassComponent;
      _currentPassComponentIsDirty = false;

      return currentPassComponent;
    }
  }

  /// Initializer.
  MultiStageComponentizedBuilder(this.componentBuilder);

  bool _currentPassComponentIsDirty = true;

  /// Build a new instance of the RIB with the given dynamic dependency
  /// as the last stage of this mult-stage building process.
  ///
  /// - note: Subsequent access to the `component` property after this
  /// method is returned will result in a separate new instance of the
  /// component, representing a new pass of the multi-stage building
  /// process.
  Router finalStageBuildWithDynamicDependency(DynamicBuildDependency dynamicDependency) {
    final router = finalStageBuildWithComponent(componentForCurrentBuildPass, dynamicDependency);

    _currentPassComponentIsDirty = true;

    return router;
  }

  /// Abstract method that must be overriden to implement the RIB building
  /// logic using the given component and dynamic dependency, as the last
  /// building stage.
  ///
  /// - note: This method should never be invoked directly. Instead
  /// consumers of this builder should invoke `finalStageBuildWithDynamicDependency`.
  Router finalStageBuildWithComponent(Component component, DynamicBuildDependency dynamicDependency) {
    throw UnsupportedError("This method should be overridden by the subclass.");
  }

  Component _currentPassComponent;
  final Component Function() componentBuilder;
  dynamic _lastComponent;
}

/// A convenient base multi-stage builder class that does not require any
/// build dynamic dependencies.
///
/// - note: If the build method requires dynamic dependency, please
/// refer to [MultiStageComponentizedBuilder].
///
/// - SeeAlso: [MultiStageComponentizedBuilder]
class SimpleMultiStageComponentizedBuilder<Component, Router>
    extends MultiStageComponentizedBuilder<Component, Router, void> {
  /// Initializer.
  SimpleMultiStageComponentizedBuilder(Component Function() componentBuilder) : super(componentBuilder);

  /// This method should not be directly invoked.
  @override
  Router finalStageBuildWithComponent(Component component, void _) {
    return finalStageBuildWithComponentSimple(component);
  }

  /// Abstract method that must be overriden to implement the RIB building
  /// logic using the given component.
  ///
  /// - note: This method should never be invoked directly. Instead
  /// consumers of this builder should invoke `finalStageBuild()`.
  /// - parameter component: The corresponding DI component to use.
  /// - returns: The router of the RIB.
  Router finalStageBuildWithComponentSimple(Component component) {
    throw UnsupportedError("This method should be overridden by the subclass.");
  }

  /// Build a new instance of the RIB as the last stage of this mult-
  /// stage building process.
  ///
  /// - note: Subsequent access to the `component` property after this
  /// method is returned will result in a separate new instance of the
  /// component, representing a new pass of the multi-stage building
  /// process.
  /// - returns: The router of the RIB.
  Router finalStageBuild() {
    return finalStageBuildWithDynamicDependency(null);
  }
}
