import 'package:ribs/ribs.dart';
import 'package:test/test.dart';

import '../mocks.dart';

main() {
  group("Worker", () {
    TestWorker worker;
    InteractorMock interactor;
    CompositeDisposable disposeBag;

    setUp(() {
      worker = TestWorker();
      interactor = InteractorMock();
      disposeBag = CompositeDisposable();
    });

    test("did start only once, bound to interactor", () async {
      expect(worker._didStartCallCount, equals(0));
      expect(worker._didStopCallCount, equals(0));

      worker.start(interactor);

      expect(worker.isStarted, isTrue);
      expect(worker._didStartCallCount, equals(0));
      expect(worker._didStopCallCount, equals(0));

      interactor.activate();
      await _nextTicker;

      expect(worker.isStarted, isTrue);
      expect(worker._didStartCallCount, equals(1));
      expect(worker._didStopCallCount, equals(0));

      interactor.deactivate();
      await _nextTicker;

      expect(worker.isStarted, isTrue);
      expect(worker._didStartCallCount, equals(1));
      expect(worker._didStopCallCount, equals(1));

      worker.start(interactor);

      expect(worker.isStarted, isTrue);
      expect(worker._didStartCallCount, equals(1));
      expect(worker._didStopCallCount, equals(1));

      interactor.activate();
      await _nextTicker;

      expect(worker.isStarted, isTrue);
      expect(worker._didStartCallCount, equals(2));
      expect(worker._didStopCallCount, equals(1));

      worker.stop();

      expect(worker.isStarted, isFalse);
      expect(worker._didStartCallCount, equals(2));
      expect(worker._didStopCallCount, equals(2));

      worker.stop();

      expect(worker.isStarted, isFalse);
      expect(worker._didStartCallCount, equals(2));
      expect(worker._didStopCallCount, equals(2));
    });

    test("start stop lifecycle", () async {
      disposeBag.newSubscription = worker.isStartedStream
          .take(1)
          .listen((isStarted) => expect(isStarted, isFalse));

      interactor.activate();
      worker.start(interactor);

      disposeBag.newSubscription = worker.isStartedStream
          .take(1)
          .listen((isStarted) => expect(isStarted, isTrue));

      worker.stop();

      disposeBag.newSubscription = worker.isStartedStream
          .take(1)
          .listen((isStarted) => expect(isStarted, isFalse));
    });
  });
}

class TestWorker extends Worker {
  var _didStartCallCount = 0;
  var _didStopCallCount = 0;

  @override
  void didStart(InteractorScope interactorScope) {
    super.didStart(interactorScope);
    _didStartCallCount++;
  }

  @override
  void didStop() {
    super.didStop();
    _didStopCallCount++;
  }
}

/// Our subjects appear to be asynchronous so we use this to wait for next cycle
Future get _nextTicker => Future.delayed(Duration(milliseconds: 1));
