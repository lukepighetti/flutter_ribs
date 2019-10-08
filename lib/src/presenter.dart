/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/Presenter.swift

/// The base protocol for all `Presenter`s.
abstract class Presentable {}

/// The base class of all `Presenter`s. A `Presenter` translates business models into values the corresponding
/// `ViewController` can consume and display. It also maps UI events to business logic method, invoked to
/// its listener.
class Presenter<ViewControllerType> extends Presentable {
  /// The view controller of this presenter.
  final ViewControllerType viewController;

  /// Initializer.
  ///
  /// - parameter viewController: The `ViewController` of this `Pesenters`.
  Presenter(this.viewController);
}
