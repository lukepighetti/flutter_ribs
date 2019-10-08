/// Based on https://github.com/uber/RIBs/blob/master/ios/RIBsTests/LaunchRouterTests.swift

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ribs/ribs.dart';

import 'mocks.dart';

main() {
  group("LaunchRouter", () {
    final interactor = InteractableMock();
    final viewController = ViewControllableMock();
    final launchRouter = LaunchRouter(interactor, viewController);

    testWidgets("launch from window", (WidgetTester tester) async {
      final controller = WindowController();
      final window = Window(controller);

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: window,
      ));

      expect(find.text(ViewControllableMock.label), findsNothing);

      launchRouter.launch(controller);

      await tester.pumpAndSettle();

      expect(find.text(ViewControllableMock.label), findsOneWidget);
    });
  });
}
