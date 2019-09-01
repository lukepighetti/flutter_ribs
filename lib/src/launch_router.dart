// import UIKit

import 'package:flutter/widgets.dart';

import 'interactor.dart';
import 'view_controllable.dart';
import 'viewable_router.dart';

/// The root `Router` of an application.
// public protocol LaunchRouting: ViewableRouting {
abstract class LaunchRouting extends ViewableRouting {
  /// Launches the router tree.
  ///
  /// - parameter window: The application window to launch from.
  // func launch(from window: UIWindow)
  launch(Widget window);
}

/// The application root router base class, that acts as the root of the router tree.
// open class LaunchRouter<InteractorType, ViewControllerType>: ViewableRouter<InteractorType, ViewControllerType>, LaunchRouting {

class LaunchRouter<InteractorType extends Interactor, ViewControllerType>
    extends ViewableRouter<InteractorType, ViewControllerType>
    implements LaunchRouting {
  /// Initializer.
  ///
  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
  /// - parameter viewController: The corresponding `ViewController` of this `Router`.
  // public override init(interactor: InteractorType, viewController: ViewControllerType) {
  //     super.init(interactor: interactor, viewController: viewController)
  // }

  LaunchRouter(InteractorType interactor, ViewControllerType viewController)
      : super(interactor, viewController);

  /// Launches the router tree.
  ///
  /// - parameter window: The window to launch the router tree in.
  // public final func launch(from window: UIWindow) {
  //     window.rootViewController = viewControllable.uiviewController
  //     window.makeKeyAndVisible()

  //     interactable.activate()
  //     load()
  // }

  launch(Widget window) {
    // TODO: attach the child? or make a widget provider
    // window.child = viewControllable.uiviewController;
    // window.makeKeyAndVisible();
    interactable.activate();
    load();
  }
}
