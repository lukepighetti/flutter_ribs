import 'package:rxdart/rxdart.dart';

import '../composite_disposable.dart';
import '../interactor.dart';

/// https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/Workflow/Workflow.swift

class Workflow<ActionableItemType> {
  void didComplete() {
    // No-op
  }

  void didFork() {
    // No-op
  }

  void didReceiveError(Error error) {
    // No-op
  }

  Workflow();

  Step<ActionableItemType, NextActionableItemType, NextValueType> onStep<NextActionableItemType, NextValueType>(
          Observable<ActionableValue<NextActionableItemType, NextValueType>> Function(ActionableItemType) onStep) =>
      Step(this, _subject.stream.take(1)).onStep((t, _) => onStep(t));

  CompositeDisposable subscribe(ActionableItemType actionableItem) {
    /// Guard compositeDisposable.count > 0
    if (_compositeDisposable.count <= 0) {
      assert(false, "Attempted to subscribe to $this before it is comitted.");
      return CompositeDisposable();
    }

    _subject.add(ActionableValue(actionableItem, null));
    return _compositeDisposable;
  }

  final _subject = PublishSubject<ActionableValue<ActionableItemType, dynamic>>();
  var _didInvokeComplete = false;
  var _didInvokeError = false;
  final _compositeDisposable = CompositeDisposable();

  _didCompleteIfNotYet() {
    /// Guard did not invoke complete
    if (_didInvokeComplete == true) return;

    /// Guard did not invoke error
    if (_didInvokeError == true) return;

    _didInvokeComplete = true;
    didComplete();
  }

  _didReceiveError(Error error) {
    _didInvokeError = true;

    didReceiveError(error);
  }
}

class Step<WorkflowActionableItemType, ActionableItemType, ValueType> {
  final Workflow<WorkflowActionableItemType> _workflow;
  Observable<ActionableValue<ActionableItemType, ValueType>> _observable;

  Step(this._workflow, this._observable);

  Step<WorkflowActionableItemType, NextActionableItemType, NextValueType> onStep<NextActionableItemType, NextValueType>(
      Observable<ActionableValue<NextActionableItemType, NextValueType>> Function(ActionableItemType, ValueType)
          onStep) {
    final confinedNextStep = _observable
        .switchMap<_Triple<bool, ActionableItemType, ValueType>>((t) {
          /// Guard item is Interactable
          final interactor = t.actionableItem;

          if (interactor != null && interactor is Interactable) {
            return interactor.isActiveStream
                .map((isActive) => _Triple<bool, ActionableItemType, ValueType>(isActive, t.actionableItem, t.value));
          } else {
            return Observable.just(_Triple(true, t.actionableItem, t.value));
          }
        })
        .where((v) => v.isActive)
        .take(1)
        .switchMap<ActionableValue<NextActionableItemType, NextValueType>>((t) => onStep(t.actionableItem, t.value))
        .take(1)
        .asBroadcastStream();

    return Step<WorkflowActionableItemType, NextActionableItemType, NextValueType>(_workflow, confinedNextStep);
  }

  Step<WorkflowActionableItemType, ActionableItemType, ValueType> onError(void Function(Error) onError) {
    _observable = _observable.doOnError((e) => onError(e));
    return this;
  }

  Workflow<WorkflowActionableItemType> commit() {
    _workflow._compositeDisposable.newSubscription = _observable.listen(
      (_) => null,
      onDone: () => _workflow._didCompleteIfNotYet(),
      onError: (error) => _workflow._didReceiveError(error),
    );

    return _workflow;
  }

  Observable<ActionableValue<ActionableItemType, ValueType>> asObservable() {
    return _observable;
  }
}

class ActionableValue<T1, T2> {
  ActionableValue(this.actionableItem, this.value);

  ActionableValue.empty()
      : actionableItem = null,
        value = null;

  final T1 actionableItem;
  final T2 value;
}

class _Triple<T1, T2, T3> {
  _Triple(this.isActive, this.actionableItem, this.value);

  final T1 isActive;
  final T2 actionableItem;
  final T3 value;
}

/// Since class extensions in Dart are non-trivial, we decided to create a method for forking
/// instead of extending Observable
Step<WorkflowActionableItemType, ActionableItemType, ValueType>
    forkWorkflow<WorkflowActionableItemType, ActionableItemType, ValueType>(
        Workflow<WorkflowActionableItemType> workflow,
        Observable<ActionableValue<ActionableItemType, ValueType>> observable) {
  workflow.didFork();

  return Step(workflow, observable);
}
