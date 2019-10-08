import 'package:flutter/material.dart';
import 'package:ribs/ribs.dart';

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
      home: _Window(),
    );
  }
}

class _Window extends StatefulWidget {
  @override
  __WindowState createState() => __WindowState();
}

class __WindowState extends State<_Window> {
  WindowController controller;

  @override
  void initState() {
    controller = WindowController();

    final dependency = AppDependency();
    final root = RootBuilder(dependency);
    final router = root.build();

    final launchRouter = LaunchRouter(router.interactable, router.viewControllable);
    launchRouter.launch(controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Window(controller);
  }
}

class AppDependency extends RootDependency {}
