import 'dart:async';

import 'package:ribs/ribs.dart';
import 'package:rxdart/rxdart.dart';

import 'package:test/test.dart';

Observable get emptyObservable => Observable.just(ActionableValue.empty()).share();

main() {
  group("workflow", () {
    test("nested steps do not repeat", () async {
      var outerStep1RunCount = 0;
      var outerStep2RunCount = 0;
      var outerStep3RunCount = 0;

      var innerStep1RunCount = 0;
      var innerStep2RunCount = 0;
      var innerStep3RunCount = 0;

      final workflow = Workflow<String>();

      workflow
          .onStep((_) {
            outerStep1RunCount++;
            return emptyObservable;
          })
          .onStep((_, __) {
            outerStep2RunCount++;
            return emptyObservable;
          })
          .onStep((_, __) {
            outerStep3RunCount++;

            final innerStep = forkWorkflow<String, void, void>(workflow, emptyObservable);

            innerStep.onStep((_, __) {
              innerStep1RunCount++;
              return emptyObservable;
            }).onStep((_, __) {
              innerStep2RunCount++;
              return emptyObservable;
            }).onStep((_, __) {
              innerStep3RunCount++;

              return emptyObservable;
            }).commit();

            return emptyObservable;
          })
          .commit()
          .subscribe("Test Actionable Item");

      await Future.delayed(Duration(milliseconds: 1));

      expect(outerStep1RunCount, equals(1));
      expect(outerStep2RunCount, equals(1));
      expect(outerStep3RunCount, equals(1));
      expect(innerStep1RunCount, equals(1));
      expect(innerStep2RunCount, equals(1));
      expect(innerStep3RunCount, equals(1));
    });

    test("receives error", () async {
      final workflow = TestWorkflow();

      workflow
          .onStep((_) {
            return emptyObservable;
          })
          .onStep((_, __) {
            return emptyObservable;
          })
          .onStep((_, __) {
            return Observable.error(WorkflowTestError());
          })
          .onStep((_, __) {
            return emptyObservable;
          })
          .commit()
          .subscribe(null);

      await Future.delayed(Duration(milliseconds: 1));

      expect(workflow.completeCallCount, equals(0));
      expect(workflow.forkCallCount, equals(0));
      expect(workflow.errorCallCount, equals(1));
    });

    test("did complete", () async {
      final workflow = TestWorkflow();
      final emptyObservable = () => Observable.just(ActionableValue.empty());

      workflow
          .onStep((_) {
            return emptyObservable();
          })
          .onStep((_, __) {
            return emptyObservable();
          })
          .onStep((_, __) {
            return emptyObservable();
          })
          .commit()
          .subscribe(null);

      await Future.delayed(Duration(milliseconds: 1));

      expect(workflow.completeCallCount, equals(1));
      expect(workflow.forkCallCount, equals(0));
      expect(workflow.errorCallCount, equals(0));
    });

    test("did fork", () async {
      final workflow = TestWorkflow();
      final emptyObservable = () => Observable.just(ActionableValue.empty());

      workflow
          .onStep((_) {
            return emptyObservable();
          })
          .onStep((_, __) {
            return emptyObservable();
          })
          .onStep((_, __) {
            return emptyObservable();
          })
          .onStep((_, __) {
            final forkedStep = forkWorkflow(workflow, emptyObservable());

            forkedStep.onStep((_, __) {
              return emptyObservable();
            }).commit();

            return emptyObservable();
          })
          .commit()
          .subscribe(null);

      await Future.delayed(Duration(milliseconds: 1));

      expect(workflow.completeCallCount, equals(1));
      expect(workflow.forkCallCount, equals(1));
      expect(workflow.errorCallCount, equals(0));
    });

    test("single invocation at root", () async {
      final workflow = TestWorkflow();

      var rootCallCount = 0;
      final emptyObservable = () => Observable.just(ActionableValue.empty());

      final rootStep = workflow.onStep((_) {
        rootCallCount++;
        return emptyObservable();
      });

      final firstFork = forkWorkflow(workflow, rootStep.asObservable());

      firstFork.onStep((_, __) {
        return emptyObservable();
      }).commit();

      final secondFork = forkWorkflow(workflow, rootStep.asObservable());

      secondFork.onStep((_, __) {
        return emptyObservable();
      }).commit();

      await Future.delayed(Duration(milliseconds: 1));

      expect(rootCallCount, equals(0));

      workflow.subscribe(null);

      await Future.delayed(Duration(milliseconds: 1));

      expect(rootCallCount, equals(1));
    });
  });
}

class WorkflowTestError extends Error {}

class TestWorkflow extends Workflow {
  var completeCallCount = 0;
  var errorCallCount = 0;
  var forkCallCount = 0;

  @override
  didComplete() {
    completeCallCount++;
  }

  @override
  didFork() {
    forkCallCount++;
  }

  @override
  didReceiveError(Error error) {
    errorCallCount++;
  }
}
