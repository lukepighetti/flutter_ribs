/// Base on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/PresentableInteractor.swift

import 'interactor.dart';

/// Base class of an `Interactor` that actually has an associated `Presenter` and `View`.
class PresentableInteractor<PresenterType> extends Interactor {
  /// The `Presenter` associated with this `Interactor`.
  final PresenterType presenter;

  /// Initializer.
  ///
  /// - note: This holds a strong reference to the given `Presenter`.
  ///
  /// - parameter presenter: The presenter associated with this `Interactor`.
  PresentableInteractor(this.presenter);

  /// Leak detection is not implemented
}
