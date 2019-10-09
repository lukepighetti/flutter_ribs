import 'package:ribs/ribs.dart';

import 'root_interactor.dart';

import '../logged_out/logged_out_builder.dart';
import '../logged_out/logged_out_interactor.dart';

abstract class RootInteractable implements Interactable, LoggedOutListener {
  RootRouting router;
  RootListener listener;
}

abstract class RootViewControllable implements ViewControllable {
  void present(ViewControllable viewController);
}

class RootRouter extends LaunchRouter<RootInteractable, RootViewControllable> implements RootRouting {
  RootRouter(RootInteractable interactor, RootViewControllable viewController, this.loggedOutBuilder)
      : super(interactor, viewController) {
    interactor.router = this;
  }

  final LoggedOutBuildable loggedOutBuilder;

  ViewableRouting loggedOut;

  @override
  didLoad() {
    super.didLoad();

    final loggedOut = loggedOutBuilder.build(interactor);
    this.loggedOut = loggedOut;
    attachChild(loggedOut);

    viewController.present(loggedOut.viewControllable);
  }
}
