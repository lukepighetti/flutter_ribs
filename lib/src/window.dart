import 'package:flutter/widgets.dart';
import 'view_controllable.dart';

class WindowController {
  final _currentView = ValueNotifier<ViewControllable>(null);

  ValueNotifier<Widget> get currentView => _currentView;

  void launch(ViewControllable view) {
    _currentView.value = view;
  }
}

class Window extends StatelessWidget {
  Window(this.controller);

  final WindowController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.currentView,
      builder: (context, value, child) {
        return value ?? Container();
      },
    );
  }
}
