/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/Interactor.swift

import 'package:rxdart/rxdart.dart';

import 'composite_disposable.dart';

/// Protocol defining the activeness of an interactor's scope.
abstract class InteractorScope {
  // The following properties must be declared in the base protocol, since `Router` internally invokes these methods.
  // In order to unit test router with a mock interactor, the mocked interactor first needs to conform to the custom
  // subclass interactor protocol, and also this base protocol to allow the `Router` implementation to execute base
  // class logic without error.

  /// Indicates if the interactor is active.
  bool get isActive;

  /// The lifecycle of this interactor.
  ///
  /// - note: Subscription to this stream always immediately returns the last event. This stream terminates after
  ///   the interactor is deallocated.
  Observable<bool> get isActiveStream;
}

/// The base protocol for all interactors.
abstract class Interactable extends InteractorScope {
  // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
  // In order to unit test router with a mock interactor, the mocked interactor first needs to conform to the custom
  // subclass interactor protocol, and also this base protocol to allow the `Router` implementation to execute base
  // class logic without error.

  /// Activate this interactor.
  ///
  /// - note: This method is internally invoked by the corresponding router. Application code should never explicitly
  ///   invoke this method.
  void activate();

  /// Deactivate this interactor.
  ///
  /// - note: This method is internally invoked by the corresponding router. Application code should never explicitly
  ///   invoke this method.
  void deactivate();
}

/// An `Interactor` defines a unit of business logic that corresponds to a router unit.
///
/// An `Interactor` has a lifecycle driven by its owner router. When the corresponding router is attached to its
/// parent, its interactor becomes active. And when the router is detached from its parent, its `Interactor` resigns
/// active.
///
/// An `Interactor` should only perform its business logic when it's currently active.
class Interactor extends Interactable {
  /// Indicates if the interactor is active.
  bool get isActive {
    if (_isActiveSubject?.value != null) {
      return _isActiveSubject.value;
    } else {
      return false;
    }
  }

  /// A stream notifying on the lifecycle of this interactor.
  Observable<bool> get isActiveStream {
    return _isActiveSubject.distinct();
  }

  /// Initializer.
  Interactor();

  /// Activate the `Interactor`.
  ///
  /// - note: This method is internally invoked by the corresponding router. Application code should never explicitly
  ///   invoke this method.
  activate() {
    if (isActive) {
      return;
    }

    activenessDisposable = CompositeDisposable();
    _isActiveSubject.add(true);

    didBecomeActive();
  }

  /// The interactor did become active.
  ///
  /// - note: This method is driven by the attachment of this interactor's owner router. Subclasses should override
  ///   this method to setup subscriptions and initial states.
  didBecomeActive() {
    // No-op
  }

  /// Deactivate this `Interactor`.
  ///
  /// - note: This method is internally invoked by the corresponding router. Application code should never explicitly
  ///   invoke this method.
  deactivate() {
    if (isActive == false) {
      return;
    }

    willResignActive();

    activenessDisposable?.dispose();

    _isActiveSubject.add(false);
  }

  /// Callend when the `Interactor` will resign the active state.
  ///
  /// This method is driven by the detachment of this interactor's owner router. Subclasses should override this
  /// method to cleanup any resources and states of the `Interactor`. The default implementation does nothing.
  willResignActive() {
    // No-op
  }

  /// MARK: - Private
  final _isActiveSubject = BehaviorSubject<bool>.seeded(false);

  CompositeDisposable activenessDisposable;

  dispose() {
    if (isActive) {
      deactivate();
    }
    _isActiveSubject.close();
  }
}

/// This is my best estimate of a class extension from Swift
class ConfinedPublishSubject = PublishSubject with ConfinedMixin, DeactivateMixin;

/// This is my best estimate of a class extension from Swift
class ConfinedBehaviorSubject = BehaviorSubject with ConfinedMixin, DeactivateMixin;

/// Interactor related `Observable` extensions.
// public extension ObservableType {
mixin ConfinedMixin on Observable {
  /// Confines the observable's subscription to the given interactor scope. The subscription is only triggered
  /// after the interactor scope is active and before the interactor scope resigns active. This composition
  /// delays the subscription but does not dispose the subscription, when the interactor scope becomes inactive.
  ///
  /// - note: This method should only be used for subscriptions outside of an `Interactor`, for cases where a
  ///   piece of logic is only executed when the bound interactor scope is active.
  ///
  /// - note: Only the latest value from this observable is emitted. Values emitted when the interactor is not
  ///   active, are ignored.
  ///
  /// - parameter interactorScope: The interactor scope whose activeness this observable is confined to.
  /// - returns: The `Observable` confined to this interactor's activeness lifecycle.
  Observable<T> confineTo<T>(InteractorScope interactorScope) {
    return Observable.combineLatest2<bool, T, _ConfinedTuple<T>>(
            interactorScope.isActiveStream, this as Observable<T>, _ConfinedTuple._create)
        .where((t) => t.isActive)
        .map((t) => t.value);
  }
}

/// A dart specific tuple for confineTo
class _ConfinedTuple<T> {
  _ConfinedTuple._(this.isActive, this.value);

  static _ConfinedTuple<T> _create<T>(bool isActive, T value) => _ConfinedTuple._(isActive, value);

  final bool isActive;
  final T value;
}

/// Interactor related `Disposable` extensions.
mixin DeactivateMixin on Subject {
  /// Disposes the subscription based on the lifecycle of the given `Interactor`. The subscription is disposed
  /// when the interactor is deactivated.
  ///
  /// - note: This is the preferred method when trying to confine a subscription to the lifecycle of an
  ///   `Interactor`.
  ///
  /// When using this composition, the subscription closure may freely retain the interactor itself, since the
  /// subscription closure is disposed once the interactor is deactivated, thus releasing the retain cycle before
  /// the interactor needs to be deallocated.
  ///
  /// If the given interactor is inactive at the time this method is invoked, the subscription is immediately
  /// terminated.
  ///
  /// - parameter interactor: The interactor to dispose the subscription based on.
  Subject disposeOnDeactivate(Interactor interactor) {
    final activenessDisposable = interactor.activenessDisposable;

    if (activenessDisposable != null) {
      activenessDisposable.addSubject(this);
    } else {
      close();
      print("Subscription immediately terminated, since $interactor is inactive.");
    }
    return this;
  }
}
