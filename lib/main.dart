import 'package:flutter_demo_3d/object3d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Object Viewer',
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text("Flutter 3D"),
        ),
        body: new Center(
          child: new Object3D(
            size: const Size(400.0, 400.0),
            path: "assets/file.obj",
          ),
        ),
      ),
    );
  }
}
