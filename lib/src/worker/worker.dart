/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/Worker/Worker.swift

import 'dart:async';

import 'package:ribs/src/composite_disposable.dart';
import 'package:rxdart/rxdart.dart';

import '../interactor.dart';

/// The base protocol of all workers that perform a self-contained piece of logic.
///
/// `Worker`s are always bound to an `Interactor`. A `Worker` can only start if its bound `Interactor` is active.
/// It is stopped when its bound interactor is deactivated.
abstract class Working {
  /// Starts the `Worker`.
  ///
  /// If the bound `InteractorScope` is active, this method starts the `Worker` immediately. Otherwise the `Worker`
  /// will start when its bound `Interactor` scope becomes active.
  ///
  /// - parameter interactorScope: The interactor scope this worker is bound to.
  void start(InteractorScope interactorScope);

  /// Stops the worker.
  ///
  /// Unlike `start`, this method always stops the worker immediately.
  void stop();

  /// Indicates if the worker is currently started.
  bool get isStarted;

  /// The lifecycle of this worker.
  ///
  /// Subscription to this stream always immediately returns the last event. This stream terminates after the
  /// `Worker` is deallocated.
  Observable<bool> get isStartedStream;
}

class Worker implements Working {
  /// Indicates if the `Worker` is started.
  bool get isStarted => _isStartedSubject.value;

  /// The lifecycle stream of this `Worker`.
  Observable<bool> get isStartedStream => _isStartedSubject.stream.distinct();

  /// Starts the `Worker`.
  ///
  /// If the bound `InteractorScope` is active, this method starts the `Worker` immediately. Otherwise the `Worker`
  /// will start when its bound `Interactor` scope becomes active.
  ///
  /// - parameter interactorScope: The interactor scope this worker is bound to.
  void start(InteractorScope interactorScope) {
    /// Guard is not started
    if (isStarted) return;

    stop();

    _isStartedSubject.add(true);

    // Create a separate scope struct to avoid passing the given scope instance, since usually
    // the given instance is the interactor itself. If the interactor holds onto the worker without
    // de-referencing it when it becomes inactive, there will be a retain cycle.
    final weakInteractorScope = WeakInteractorScope(interactorScope);

    _bind(weakInteractorScope);
  }

  /// Called when the the worker has started.
  ///
  /// Subclasses should override this method and implment any logic that they would want to execute when the `Worker`
  /// starts. The default implementation does nothing.
  ///
  /// - parameter interactorScope: The interactor scope this `Worker` is bound to.
  void didStart(InteractorScope interactorScope) {}

  /// Stops the worker.
  ///
  /// Unlike `start`, this method always stops the worker immediately.
  void stop() {
    /// Guard is started
    if (isStarted == false) return;

    _isStartedSubject.add(false);

    _executeStop();
  }

  /// Called when the worker has stopped.
  ///
  /// Subclasses should override this method abnd implement any cleanup logic that they might want to execute when
  /// the `Worker` stops. The default implementation does noting.
  ///
  /// - note: All subscriptions added to the disposable provided in the `didStart` method are automatically disposed
  /// when the worker stops.
  void didStop() {
    // No-op
  }

  final _isStartedSubject = BehaviorSubject<bool>.seeded(false);
  CompositeDisposable _disposable;
  StreamSubscription _interactorBindingDisposable;

  _bind(InteractorScope interactorScope) {
    _unbindInteractor();

    _interactorBindingDisposable = interactorScope.isActiveStream.listen((isInteractorActive) {
      if (isInteractorActive) {
        if (this.isStarted == true) {
          this._executeStart(interactorScope);
        }
      } else {
        this._executeStop();
      }
    });

    /// TODO: continue implementing
  }

  _executeStart(InteractorScope interactorScope) {
    _disposable ??= CompositeDisposable();
    didStart(interactorScope);
  }

  _executeStop() {
    /// Guard disposable is not null
    if (_disposable == null) return;

    _disposable.dispose();
    _disposable = null;

    didStop();
  }

  _unbindInteractor() {
    _interactorBindingDisposable?.cancel();
  }

  dispose() {
    stop();
    _unbindInteractor();
    _isStartedSubject.close();
  }
}

class WeakInteractorScope extends InteractorScope {
  WeakInteractorScope(this.sourceScope);

  final InteractorScope sourceScope;

  @override
  bool get isActive => sourceScope?.isActive ?? false;

  @override
  Observable<bool> get isActiveStream => sourceScope?.isActiveStream ?? Observable.just(false);
}
