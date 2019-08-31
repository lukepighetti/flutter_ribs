// import Foundation
import 'package:meta/meta.dart';

import 'builder.dart';
import 'di/component.dart';
import 'router.dart';

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
// open class ComponentizedBuilder<Component, Router, DynamicBuildDependency, DynamicComponentDependency>: Buildable {

class ComponentizedBuilder<DynamicBuildDependency, DynamicComponentDependency>
    extends Buildable {
  // Builder should not directly retain an instance of the component.
  // That would make the component's lifecycle longer than the built
  // RIB. Instead, whenever a new instance of the RIB is built, a new
  // instance of the DI component should also be instantiated.
  /// Initializer.
  ///
  /// - parameter componentBuilder: The closure to instantiate a new
  /// instance of the DI component that should be paired with this RIB.
  // public init(componentBuilder: @escaping (DynamicComponentDependency) -> Component) {
  //     self.componentBuilder = componentBuilder
  // }

  ComponentizedBuilder({
    @required Component Function(DynamicComponentDependency) componentBuilder,
  }) : this._componentBuilder = componentBuilder;

  /// Build a new instance of the RIB with the given dynamic dependencies.
  ///
  /// - parameter dynamicBuildDependency: The dynamic dependency to use
  /// to build the RIB.
  /// - parameter dynamicComponentDependency: The dynamic dependency to
  /// use to instantiate the component.
  /// - returns: The router of the RIB.
  // public final func build(withDynamicBuildDependency dynamicBuildDependency: DynamicBuildDependency, dynamicComponentDependency: DynamicComponentDependency) -> Router {
  //     return build(withDynamicBuildDependency: dynamicBuildDependency, dynamicComponentDependency: dynamicComponentDependency).1
  // }

  Router buildRouter(DynamicBuildDependency dynamicBuildDependency,
      DynamicComponentDependency dynamicComponentDependency) {
    return buildTuple(dynamicBuildDependency, dynamicComponentDependency)
        .router;
  }

  /// Build a new instance of the RIB with the given dynamic dependencies.
  ///
  /// - parameter dynamicBuildDependency: The dynamic dependency to use
  /// to build the RIB.
  /// - parameter dynamicComponentDependency: The dynamic dependency to
  /// use to instantiate the component.
  /// - returns: The tuple of component and router of the RIB.
  // public final func build(withDynamicBuildDependency dynamicBuildDependency: DynamicBuildDependency, dynamicComponentDependency: DynamicComponentDependency) -> (Component, Router) {
  //     let component = componentBuilder(dynamicComponentDependency)

  //     // Ensure each componentBuilder invocation produces a new component
  //     // instance.
  //     let newComponent = component as AnyObject
  //     if lastComponent === newComponent {
  //         assertionFailure("\(self) componentBuilder should produce new instances of component when build is invoked.")
  //     }
  //     lastComponent = newComponent

  //     return (component, build(with: component, dynamicBuildDependency))
  // }
  _BuildTuple buildTuple(DynamicBuildDependency dynamicBuildDependency,
      DynamicComponentDependency dynamicComponentDependency) {
    final component = _componentBuilder(dynamicComponentDependency);

    /// TODO: create a copy of a component without being a linked instance
    final newComponent = component as dynamic;

    assert(component != newComponent,
        "$this componentBuilder should produce new instances of component when build is invoked.");

    _lastComponent = newComponent;

    return _BuildTuple(component, build(component, dynamicBuildDependency));
  }
  //     public final func build(withDynamicBuildDependency dynamicBuildDependency: DynamicBuildDependency, dynamicComponentDependency: DynamicComponentDependency) -> (Component, Router) {
  //     let component = componentBuilder(dynamicComponentDependency)

  //     // Ensure each componentBuilder invocation produces a new component
  //     // instance.
  //     let newComponent = component as AnyObject
  //     if lastComponent === newComponent {
  //         assertionFailure("\(self) componentBuilder should produce new instances of component when build is invoked.")
  //     }
  //     lastComponent = newComponent

  //     return (component, build(with: component, dynamicBuildDependency))
  // }

  /// Abstract method that must be overriden to implement the RIB building
  /// logic using the given component and dynamic dependency.
  ///
  /// - note: This method should never be invoked directly. Instead
  /// consumers of this builder should invoke `build(with dynamicDependency:)`.
  /// - parameter component: The corresponding DI component to use.
  /// - parameter dynamicBuildDependency: The given dynamic dependency.
  /// - returns: The router of the RIB.
  // open func build(with component: Component, _ dynamicBuildDependency: DynamicBuildDependency) -> Router {
  //     fatalError("This method should be oevrriden by the subclass.")
  // }

  Router build(
      Component component, DynamicBuildDependency dynamicBuildDependency) {
    throw UnimplementedError(
        "This method should be oevrriden by the subclass.");
  }

  // MARK: - Private
  // private let componentBuilder: (DynamicComponentDependency) -> Component
  final Component Function(DynamicComponentDependency) _componentBuilder;
  // private weak var lastComponent: AnyObject?
  dynamic _lastComponent;
}

class _BuildTuple {
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
// open class SimpleComponentizedBuilder<Component, Router>: ComponentizedBuilder<Component, Router, (), ()> {
class SimpleComponentizedBuilder<DynamicBuildDependency,
        DynamicComponentDependency>
    extends ComponentizedBuilder<DynamicBuildDependency,
        DynamicComponentDependency> {
  /// Initializer.
  ///
  /// - parameter componentBuilder: The closure to instantiate a new
  /// instance of the DI component that should be paired with this RIB.
  // #if compiler(>=5.0)
  //     public init(componentBuilder: @escaping () -> Component) {
  //         super.init(componentBuilder: componentBuilder)
  //     }
  // #else
  //     public override init(componentBuilder: @escaping () -> Component) {
  //         super.init(componentBuilder: componentBuilder)
  //     }
  // #endif
  SimpleComponentizedBuilder(Function(Component) componentBuilder);

  /// This method should not be directly invoked.
  // public final override func build(with component: Component, _ dynamicDependency: ()) -> Router {
  //     return build(with: component)
  // }
  @override
  Router build(
      Component component, DynamicBuildDependency dynamicBuildDependency) {
    return buildSimple(component);
  }

  /// Abstract method that must be overriden to implement the RIB building
  /// logic using the given component.
  ///
  /// - note: This method should never be invoked directly. Instead
  /// consumers of this builder should invoke `build(with dynamicDependency:)`.
  /// - parameter component: The corresponding DI component to use.
  /// - returns: The router of the RIB.
  // open func build(with component: Component) -> Router {
  //     fatalError("This method should be oevrriden by the subclass.")
  // }
  Router buildSimple(Component component) {
    throw UnimplementedError(
        "This method should be oevrriden by the subclass.");
  }

  /// Build a new instance of the RIB.
  ///
  /// - returns: The router of the RIB.
  // public final func build() -> Router {
  //     return build(withDynamicBuildDependency: (), dynamicComponentDependency: ())
  // }

  Router buildSimpler() {
    return buildTuple(null, null).router;
  }
}
