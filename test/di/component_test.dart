import 'package:ribs/src/di/dependency.dart';
import 'package:test/test.dart';

import 'package:ribs/ribs.dart';

main() {
  group("Component", () {
    test("shared", () {
      final component = TestComponent(dependency: EmptyComponent());

      expect(component.share, equals(component.share));
      expect(component.share2, equals(component.share2));
      expect(component.share, isNot(equals(component.share2)));

      expect(component._callCount, equals(3));
    });

    test("shared optional", () {
      final component = TestComponent(dependency: EmptyComponent());
      expect(component.optionalShare, equals(component.expectedOptionalShare));
    });
  });
}

class TestComponent extends Component<EmptyComponent> {
  TestComponent({Dependency dependency}) : super(dependency);

  var _callCount = 0;

  final ClassProtocol expectedOptionalShare = ClassProtocolImpl();

  Object get share {
    _callCount++;
    return shared<Object>("share", () => Object());
  }

  Object get share2 {
    return shared<Object>("share2", () => Object());
  }

  ClassProtocol get optionalShare {
    return shared<ClassProtocol>(
        "optionalShare", () => this.expectedOptionalShare);
  }
}

abstract class ClassProtocol {}

class ClassProtocolImpl implements ClassProtocol {}
