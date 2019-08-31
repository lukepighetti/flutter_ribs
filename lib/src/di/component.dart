import 'dependency.dart';

/// The base class for all components.
///
/// A component defines private properties a RIB provides to its internal `Router`, `Interactor`, `Presenter` and
/// view units, as well as public properties to its child RIBs.
///
/// A component subclass implementation should conform to child 'Dependency' protocols, defined by all of its immediate
/// children.
// open class Component<DependencyType>: Dependency {
class Component<T> extends Dependency {
  /// The dependency of this `Component`.
  // public let dependency: DependencyType
  final T dependency;

  /// Initializer.
  ///
  /// - parameter dependency: The dependency of this `Component`, usually provided by the parent `Component`.
  // public init(dependency: DependencyType) {
  //     self.dependency = dependency
  // }
  Component(this.dependency);

  /// Used to create a shared dependency in your `Component` sub-class. Shared dependencies are retained and reused
  /// by the component. Each dependent asking for this dependency will receive the same instance while the component
  /// is alive.
  ///
  /// - note: Any shared dependency's constructor may not switch threads as this might cause a deadlock.
  ///
  /// - parameter factory: The closure to construct the dependency.
  /// - returns: The instance.
  // public final func shared<T>(__function: String = #function, _ factory: () -> T) -> T {
  //     lock.lock()
  //     defer {
  //         lock.unlock()
  //     }

  //     // Additional nil coalescing is needed to mitigate a Swift bug appearing in Xcode 10.
  //     // see https://bugs.swift.org/browse/SR-8704.
  //     // Without this measure, calling `shared` from a function that returns an optional type
  //     // will always pass the check below and return nil if the instance is not initialized.
  //     if let instance = (sharedInstances[__function] as? T?) ?? nil {
  //         return instance
  //     }

  //     let instance = factory()
  //     sharedInstances[__function] = instance

  //     return instance
  // }

  K shared<K>(String function, K Function() generator) {
    var instance = _sharedInstances[function];

    // Additional nil coalescing is needed to mitigate a Swift bug appearing in Xcode 10.
    // see https://bugs.swift.org/browse/SR-8704.
    // Without this measure, calling `shared` from a function that returns an optional type
    // will always pass the check below and return nil if the instance is not initialized.
    if (instance != null && instance is K) {
      return instance;
    }

    instance = generator();
    _sharedInstances[function] = instance;

    return instance;
  }

  // MARK: - Private
  // private var sharedInstances = [String: Any]()
  final _sharedInstances = Map<String, dynamic>();
  // private let lock = NSRecursiveLock()
  /// not applicable to Dart, because it is single threaded
}

// /// The special empty component.
// open class EmptyComponent: EmptyDependency {

//     /// Initializer.
//     public init() {}
// }

class EmptyComponent extends EmptyDependency {}
