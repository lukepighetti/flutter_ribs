/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBsTests/MultiStageComponentizedBuilderTests.swift

import 'package:ribs/ribs.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group("MultiStageComponentizedBuilder", () {
    final builder = MockMultiStageComponentizedBuilder(() => MockComponent());

    test("same pass, verify same instance", () {
      var instance = builder.componentForCurrentBuildPass;

      for (var i = 0; i < 100; i++) {
        expect(instance, equals(builder.componentForCurrentBuildPass));

        instance = builder.componentForCurrentBuildPass;
      }
    });

    test("multiple passes, verify different instances", () {
      builder._finalStageBuildHandler = (MockComponent component, int dynamicDependency) {
        expect(dynamicDependency, equals(42));
        return MockSimpleRouter();
      };

      final firstPassInstance = builder.componentForCurrentBuildPass;

      builder.finalStageBuildWithDynamicDependency(42);

      final secondPassInstance = builder.componentForCurrentBuildPass;

      expect(firstPassInstance, isNot(equals(secondPassInstance)));
    });

    test("builder returns same instance, verify assertion", () {
      ///
      final component = MockComponent();

      final sameInstanceBuilder = MockMultiStageComponentizedBuilder(() => component);

      sameInstanceBuilder._finalStageBuildHandler = (MockComponent component, int dynamicDependency) {
        expect(dynamicDependency, equals(42));
        return MockSimpleRouter();
      };

      expect(
        () => sameInstanceBuilder.finalStageBuildWithDynamicDependency(42),
        returnsNormally,
      );

      expect(() => sameInstanceBuilder.finalStageBuildWithDynamicDependency(42), throwsAssertionError);

      expect(() => sameInstanceBuilder.componentForCurrentBuildPass, throwsAssertionError);
    });
  });
}

class MockComponent {}

class MockSimpleRouter {}

class MockMultiStageComponentizedBuilder extends MultiStageComponentizedBuilder<MockComponent, MockSimpleRouter, int> {
  MockMultiStageComponentizedBuilder(MockComponent Function() componentBuilder) : super(componentBuilder);

  MockSimpleRouter Function(MockComponent, int) _finalStageBuildHandler;

  @override
  MockSimpleRouter finalStageBuildWithComponent(MockComponent component, int dynamicDependency) {
    return _finalStageBuildHandler(component, dynamicDependency);
  }
}
