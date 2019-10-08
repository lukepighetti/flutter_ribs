/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/ComponentizedBuilder.swift

import 'builder.dart';

/// Utility that instantiates a RIB and sets up its internal wirings.
/// This class ensures the strict one to one relationship between a
/// new instance of the RIB and a single new instance of the component.
/// Every time a new RIB is built a new instance of the corresponding
/// component is also instantiated.
///
/// This is the most generic version of the builder class that supports
/// both dynamic dependencies injected when building the RIB as well
/// as dynamic dependencies for instantiating the component. For more
/// convenient base class, please refer to `SimpleComponentizedBuilder`.
///
/// - note: Subclasses should override the `build(with)` method to
/// implement the actual RIB building logic, with the given component
/// and dynamic dependency.
/// - SeeAlso: SimpleComponentizedBuilder
class ComponentizedBuilder<Component, Router, DynamicBuildDependency, DynamicComponentDependency> extends Buildable {
  // Builder should not directly retain an instance of the component.
  // That would make the component's lifecycle longer than the built
  // RIB. Instead, whenever a new instance of the RIB is built, a new
  // instance of the DI component should also be instantiated.
  /// Initializer.
  ///
  /// - parameter componentBuilder: The closure to instantiate a new
  /// instance of the DI component that should be paired with this RIB.
  ComponentizedBuilder(
    Component Function(DynamicComponentDependency) componentBuilder,
  ) : this._componentBuilder = componentBuilder;

  /// Build a new instance of the RIB with the given dynamic dependencies.
  ///
  /// - parameter dynamicBuildDependency: The dynamic dependency to use
  /// to build the RIB.
  /// - parameter dynamicComponentDependency: The dynamic dependency to
  /// use to instantiate the component.
  /// - returns: The router of the RIB.
  Router buildRouter(
      DynamicBuildDependency dynamicBuildDependency, DynamicComponentDependency dynamicComponentDependency) {
    return buildComponentAndRouter(dynamicBuildDependency, dynamicComponentDependency).router;
  }

  /// Build a new instance of the RIB with the given dynamic dependencies.
  ///
  /// - parameter dynamicBuildDependency: The dynamic dependency to use
  /// to build the RIB.
  /// - parameter dynamicComponentDependency: The dynamic dependency to
  /// use to instantiate the component.
  /// - returns: The tuple of component and router of the RIB.
  _BuildTuple<Component, Router> buildComponentAndRouter(
      DynamicBuildDependency dynamicBuildDependency, DynamicComponentDependency dynamicComponentDependency) {
    final component = _componentBuilder(dynamicComponentDependency);
    final newComponent = _componentBuilder(dynamicComponentDependency);

    // Ensure each componentBuilder invocation produces a new component
    // instance.
    if (_lastComponent == newComponent) {
      assert(false, "$this componentBuilder should produce new instances of component when build is invoked.");
    }

    _lastComponent = newComponent;

    return _BuildTuple(component, build(component, dynamicBuildDependency));
  }

  /// Abstract method that must be overriden to implement the RIB building
  /// logic using the given component and dynamic dependency.
  ///
  /// - note: This method should never be invoked directly. Instead
  /// consumers of this builder should invoke `build(with dynamicDependency:)`.
  /// - parameter component: The corresponding DI component to use.
  /// - parameter dynamicBuildDependency: The given dynamic dependency.
  /// - returns: The router of the RIB.
  Router build(Component component, DynamicBuildDependency dynamicBuildDependency) {
    throw UnimplementedError("This method should be oevrriden by the subclass.");
  }

  // MARK: - Private
  final Component Function(DynamicComponentDependency) _componentBuilder;
  dynamic _lastComponent;
}

/// Since Dart doesn't have support for tuples, we need a helper data class
class _BuildTuple<Component, Router> {
  _BuildTuple(this.component, this.router);

  final Component component;
  final Router router;
}

/// A convenient base builder class that does not require any build or
/// component dynamic dependencies.
///
/// - note: If the build method requires dynamic dependency, please
/// refer to `DynamicBuildComponentizedBuilder`. If component instantiation
/// requires dynamic dependency, please refer to `DynamicComponentizedBuilder`.
/// If both require dynamic dependencies, please use `ComponentizedBuilder`.
/// - SeeAlso: ComponentizedBuilder
class SimpleComponentizedBuilder<Component, Router> extends ComponentizedBuilder<Component, Router, void, void> {
  /// Initializer.
  ///
  /// - parameter componentBuilder: The closure to instantiate a new
  /// instance of the DI component that should be paired with this RIB.
  SimpleComponentizedBuilder(Function(Component) componentBuilder) : super(componentBuilder);

  /// This method should not be directly invoked.
  @override
  Router build(Component component, dynamic _) {
    return buildSimple(component);
  }

  /// Abstract method that must be overriden to implement the RIB building
  /// logic using the given component.
  ///
  /// - note: This method should never be invoked directly. Instead
  /// consumers of this builder should invoke `build(with dynamicDependency:)`.
  /// - parameter component: The corresponding DI component to use.
  /// - returns: The router of the RIB.
  Router buildSimple(Component component) {
    throw UnimplementedError("This method should be oevrriden by the subclass.");
  }

  /// Build a new instance of the RIB.
  ///
  /// - returns: The router of the RIB.
  Router buildInstance() {
    return buildComponentAndRouter(null, null).router;
  }
}
