import 'package:flutter/material.dart';
import 'package:ribs/ribs.dart';

import 'app_start/app_component.dart';
import 'root/root_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ribs Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Material(
        child: _Window(),
      ),

      /// Attach the WindowController to the navigator
      navigatorKey: WindowController.navigator,
    );
  }
}

class _Window extends StatefulWidget {
  @override
  __WindowState createState() => __WindowState();
}

class __WindowState extends State<_Window> {
  WindowController windowController;
  LaunchRouting launchRouter;

  var _isReady = false;

  @override
  void initState() {
    final windowController = WindowController();
    this.windowController = windowController;

    final launchRouter = RootBuilder(AppComponent()).build();
    this.launchRouter = launchRouter;

    /// Launch right after build so we can access [WindowController.push] in our ViewControllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        launchRouter.launch(windowController);
        _isReady = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady)
      return Window(windowController);
    else
      return Material();
  }
}
