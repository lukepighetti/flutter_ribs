/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/ViewableRouter.swift

import 'interactor.dart';
import 'router.dart';
import 'view_controllable.dart';

/// The base protocol for all routers that own their own view controllers.
abstract class ViewableRouting extends Routing {
  // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
  // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
  // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
  // base class logic without error.

  /// The base view controllable associated with this `Router`.
  ViewControllable get viewControllable;
}

/// The base class of all routers that owns view controllers, representing application states.
///
/// A `Router` acts on inputs from its corresponding interactor, to manipulate application state and view state,
/// forming a tree of routers that drives the tree of view controllers. Router drives the lifecycle of its owned
/// interactor. `Router`s should always use helper builders to instantiate children `Router`s.
class ViewableRouter<InteractorType extends Interactable, ViewControllerType> extends Router<InteractorType>
    implements ViewableRouting {
  /// The corresponding `ViewController` owned by this `Router`.
  final ViewControllerType viewController;

  /// The base `ViewControllable` associated with this `Router`.
  final ViewControllable viewControllable;

  /// Initializer.
  ///
  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
  /// - parameter viewController: The corresponding `ViewController` of this `Router`.
  ViewableRouter(InteractorType interactor, this.viewController)
      : this.viewControllable = viewController as ViewControllable,
        super(interactor);

  /// MARK: - Internal
  internalDidLoad() {
    super.internalDidLoad();
  }

  // NOTE: Leak detection is currently omitted
}
