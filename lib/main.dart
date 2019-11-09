import 'package:flutter_demo_3d/object3d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Viewer',
      home: Scaffold(
        backgroundColor: Color.fromRGBO(33, 33, 33, 1),
        appBar: AppBar(
          title: const Text("Flutter 3D"),
        ),
        body: Center(
          child: Object3D(
            size: const Size(100.0, 100.0),
            zoom: 30.0,
            path: "assets/brain.obj",
          ),
        ),
      ),
    );
  }
}
