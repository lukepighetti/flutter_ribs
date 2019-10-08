/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBs/Classes/Workflow/Workflow.swift

import 'package:rxdart/rxdart.dart';

import '../composite_disposable.dart';
import '../interactor.dart';

/// Defines the base class for a sequence of steps that execute a flow through the application RIB tree.
///
/// At each step of a `Workflow` is a pair of value and actionable item. The value can be used to make logic decisions.
/// The actionable item is invoked to perform logic for the step. Typically the actionable item is the `Interactor` of a
/// RIB.
///
/// A workflow should always start at the root of the tree.
class Workflow<ActionableItemType> {
  /// Called when the last step observable is completed.
  ///
  /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
  /// The default implementation does nothing.
  void didComplete() {
    // No-op
  }

  /// Called when the `Workflow` is forked.
  ///
  /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
  /// The default implementation does nothing.
  void didFork() {
    // No-op
  }

  /// Called when the last step observable is has error.
  ///
  /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
  /// The default implementation does nothing.
  void didReceiveError(Error error) {
    // No-op
  }

  /// Initializer.
  Workflow();

  /// Execute the given closure as the root step.
  ///
  /// - parameter onStep: The closure to execute for the root step.
  /// - returns: The next step.
  Step<ActionableItemType, NextActionableItemType, NextValueType> onStep<NextActionableItemType, NextValueType>(
          Observable<ActionableValue<NextActionableItemType, NextValueType>> Function(ActionableItemType) onStep) =>
      Step(this, _subject.stream.take(1)).onStep((t, _) => onStep(t));

  /// Subscribe and start the `Workflow` sequence.
  ///
  /// - parameter actionableItem: The initial actionable item for the first step.
  /// - returns: The disposable of this workflow.
  CompositeDisposable subscribe(ActionableItemType actionableItem) {
    /// Guard compositeDisposable.count > 0
    if (_compositeDisposable.count <= 0) {
      assert(false, "Attempted to subscribe to $this before it is comitted.");
      return CompositeDisposable();
    }

    _subject.add(ActionableValue(actionableItem, null));
    return _compositeDisposable;
  }

  /// MARK: - Private
  final _subject = PublishSubject<ActionableValue<ActionableItemType, dynamic>>();
  var _didInvokeComplete = false;
  var _didInvokeError = false;

  /// The composite disposable that contains all subscriptions including the original workflow
  /// as well as all the forked ones.
  final _compositeDisposable = CompositeDisposable();

  _didCompleteIfNotYet() {
    // Since a workflow may be forked to produce multiple subscribed Rx chains, we should
    // ensure the didComplete method is only invoked once per Workflow instance. See `Step.commit`
    // on why the side-effects must be added at the end of the Rx chains.

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

/// Defines a single step in a `Workflow`.
///
/// A step may produce a next step with a new value and actionable item, eventually forming a sequence of `Workflow`
/// steps.
///
/// Steps are asynchronous by nature.
class Step<WorkflowActionableItemType, ActionableItemType, ValueType> {
  final Workflow<WorkflowActionableItemType> _workflow;
  Observable<ActionableValue<ActionableItemType, ValueType>> _observable;

  Step(this._workflow, this._observable);

  /// Executes the given closure for this step.
  ///
  /// - parameter onStep: The closure to execute for the `Step`.
  /// - returns: The next step.
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

  /// Executes the given closure when the `Step` produces an error.
  ///
  /// - parameter onError: The closure to execute when an error occurs.
  /// - returns: This step.
  Step<WorkflowActionableItemType, ActionableItemType, ValueType> onError(void Function(Error) onError) {
    _observable = _observable.doOnError((e) => onError(e));
    return this;
  }

  /// Commit the steps of the `Workflow` sequence.
  ///
  /// - returns: The committed `Workflow`.
  Workflow<WorkflowActionableItemType> commit() {
    _workflow._compositeDisposable.newSubscription = _observable.listen(
      (_) => null,
      onDone: () => _workflow._didCompleteIfNotYet(),
      onError: (error) => _workflow._didReceiveError(error),
    );

    return _workflow;
  }

  /// Convert the `Workflow` into an obseravble.
  ///
  /// - returns: The observable representation of this `Workflow`.
  Observable<ActionableValue<ActionableItemType, ValueType>> asObservable() {
    return _observable;
  }
}

/// Since Dart doesn't have tuples, we need a data class
class ActionableValue<T1, T2> {
  ActionableValue(this.actionableItem, this.value);

  ActionableValue.empty()
      : actionableItem = null,
        value = null;

  final T1 actionableItem;
  final T2 value;
}

/// Since Dart doesn't have tuples, we need a data class
class _Triple<T1, T2, T3> {
  _Triple(this.isActive, this.actionableItem, this.value);

  final T1 isActive;
  final T2 actionableItem;
  final T3 value;
}

// Since class extensions in Dart are non-trivial, we decided to create a method for forking
// instead of extending Observable.

/// Fork the step from this obervable.
///
/// - parameter workflow: The workflow this step belongs to.
/// - returns: The newly forked step in the workflow. `null` if this observable does not conform to the required
///   generic type of (ActionableItemType, ValueType).
Step<WorkflowActionableItemType, ActionableItemType, ValueType>
    forkWorkflow<WorkflowActionableItemType, ActionableItemType, ValueType>(
        Workflow<WorkflowActionableItemType> workflow,
        Observable<ActionableValue<ActionableItemType, ValueType>> observable) {
  workflow.didFork();

  return Step(workflow, observable);
}
