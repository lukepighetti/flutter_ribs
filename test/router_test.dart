import 'dart:async';

import 'package:test/test.dart';

import 'package:ribs/ribs.dart';

import 'mocks.dart';

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
