import 'package:flutter/widgets.dart';
import 'package:ribs/ribs.dart';

import 'root_interactor.dart';
import 'root_router.dart';

abstract class RootPresentableListener {
  // Declare properties and methods that the view controller can invoke to perform
  // business logic, such as signIn(). This protocol is implemented by the corresponding
  // interactor class.
}

class RootViewController extends StatelessWidget with RootViewControllable implements RootPresentable {
  @override
  var listener;

  @override
  void present(ViewControllable viewController) {
    // present(viewController);
    /// TODO: implement present
  }

  @override
  Widget get uiviewController => this;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("RootViewController"),
    );
  }
}
