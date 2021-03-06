/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBsTests/ComponentizedBuilderTests.swift

import 'package:ribs/ribs.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group("ComponentizedBuilder", () {
    test("builder returns same instance, verify assertion", () async {
      final component = MockComponent();
      final sameInstanceBuilder = MockComponentizedBuilder((_) => component);
      sameInstanceBuilder.buildHandler = (component, _) => MockSimpleRouter();

      expect(() => sameInstanceBuilder.buildRouter(null, null), returnsNormally);
      expect(() => sameInstanceBuilder.buildRouter(null, null), throwsAssertionError);
    });

    test("builder returns same instance, verify assertion", () async {
      final sameInstanceBuilder = MockComponentizedBuilder((_) => MockComponent());
      sameInstanceBuilder.buildHandler = (component, _) => MockSimpleRouter();

      expect(() => sameInstanceBuilder.buildRouter(null, null), returnsNormally);
      expect(() => sameInstanceBuilder.buildRouter(null, null), returnsNormally);
    });
  });
}

class MockComponent {}

class MockSimpleRouter {}

class MockComponentizedBuilder extends ComponentizedBuilder<MockComponent, MockSimpleRouter, void, void> {
  MockComponentizedBuilder(MockComponent Function(void) componentBuilder) : super(componentBuilder);

  MockSimpleRouter Function(MockComponent, void) buildHandler;

  @override
  MockSimpleRouter build(MockComponent component, dynamic dynamicBuildDependency) {
    if (buildHandler == null) throw StateError("buildHandler must not be null");

    return buildHandler(component, dynamicBuildDependency);
  }
}
