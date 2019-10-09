/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/LaunchRouter.swift

import 'interactor.dart';
import 'view_controllable.dart';
import 'viewable_router.dart';
import 'window.dart';

/// The root `Router` of an application.
abstract class LaunchRouting extends ViewableRouting {
  /// Launches the router tree.
  ///
  /// - parameter window: The application window to launch from.
  launch(WindowController window);
}

/// The application root router base class, that acts as the root of the router tree.
class LaunchRouter<InteractorType extends Interactable, ViewControllerType extends ViewControllable>
    extends ViewableRouter<InteractorType, ViewControllerType> implements LaunchRouting {
  /// Initializer.
  ///
  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
  /// - parameter viewController: The corresponding `ViewController` of this `Router`.
  LaunchRouter(InteractorType interactor, ViewControllerType viewController) : super(interactor, viewController);

  /// Launches the router tree.
  ///
  /// - parameter window: The window to launch the router tree in.
  launch(WindowController window) {
    window.launch(viewController);

    /// TODO: implement window.makeKeyAndVisible()
    /// https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/LaunchRouter.swift#L44
    ///
    /// So it appears that iOS lets people create windows in a stack and specify which one is on top
    /// of the stack using UIWindow.makeKeyAndVisible();
    ///
    /// We might have to build our own Stack in Flutter that allows us to achieve this same functionality

    interactable.activate();
    load();
  }
}
