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

  @override
  void initState() {
    final windowController = WindowController();
    this.windowController = windowController;

    final launchRouter = RootBuilder(AppComponent()).build();
    this.launchRouter = launchRouter;

    launchRouter.launch(windowController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Window(windowController);
  }
}
