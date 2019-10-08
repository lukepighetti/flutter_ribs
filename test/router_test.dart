import 'dart:async';

import 'package:ribs/ribs.dart';
import 'package:test/test.dart';

import 'mocks.dart';

/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBsTests/RouterTests.swift
main() {
  group("Router", () {
    Router router;
    StreamSubscription lifecycleDisposable;

    setUp(() {
      router = Router(interactor: InteractableMock());
    });

    tearDown(() {
      lifecycleDisposable.cancel();
    });

    test("load and verify lifecycle observable", () async {
      RouterLifecycle currentLifecycle;
      var didComplete = false;

      lifecycleDisposable = router.lifecycle.listen((lifecycle) {
        currentLifecycle = lifecycle;
      }, onDone: () {
        currentLifecycle = null;
        didComplete = true;
      });

      expect(currentLifecycle, isNull);
      expect(didComplete, isFalse);

      router.load();

      expect(currentLifecycle, equals(RouterLifecycle.didLoad));
      expect(didComplete, isFalse);

      router.dispose();

      expect(currentLifecycle, isNull);
      expect(didComplete, isTrue);
    });
  });
}
