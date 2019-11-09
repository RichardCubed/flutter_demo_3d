library flutter_3d_obj;

import 'dart:ui';

import 'package:flutter_demo_3d/model.dart';
import 'package:flutter_demo_3d/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math.dart' as Matrix;

class Object3D extends StatefulWidget {
  final Size size;
  final String path;
  final double zoom;

  Object3D({@required this.size, @required this.path, @required this.zoom});

  @override
  _Object3DState createState() => _Object3DState();
}

class _Object3DState extends State<Object3D> {
  double angleX = 0.0;
  double angleY = 0.0;
  double angleZ = 0.0;

  double zoom = 0.0;
  String object;

  void initState() {
    rootBundle.loadString(widget.path).then((value) {
      setState(() {
        object = value;
      });
    });
    super.initState();
  }

  _dragX(DragUpdateDetails update) {
    setState(() {
      angleX += update.delta.dy;
      if (angleX > 360)
        angleX = angleX - 360;
      else if (angleX < 0) angleX = 360 - angleX;
    });
  }

  _dragY(DragUpdateDetails update) {
    setState(() {
      angleY += update.delta.dx;
      if (angleY > 360)
        angleY = angleY - 360;
      else if (angleY < 0) angleY = 360 - angleY;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: CustomPaint(
          painter: _ObjectPainter(widget.size, object, angleX, angleY, angleZ, widget.zoom),
          size: widget.size,
        ),
        onHorizontalDragUpdate: (DragUpdateDetails update) => _dragY(update),
        onVerticalDragUpdate: (DragUpdateDetails update) => _dragX(update));
  }
}

/*
 *  To render our 3D model we'll need to implement the CustomPainter interface and
 *  handle drawing to the canvas ourselves.
 *  https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
 */
class _ObjectPainter extends CustomPainter {

  final String object;

  double _viewPortX = 0.0;
  double _viewPortY = 0.0;
  double _zoom = 0.0;

  Vector3 camera;
  Vector3 light;

  double angleX;
  double angleY;
  double angleZ;

  Color color;
  Size size;

  Model model;

  _ObjectPainter(this.size, this.object, this.angleX, this.angleY, this.angleZ, this._zoom) {
    camera = Vector3(0.0, 0.0, 0.0);
    light = Vector3(0.0, 0.0, 100.0);
    color = Color.fromRGBO(255, 255, 255, 1);
    _viewPortX = (size.width / 2).toDouble();
    _viewPortY = (size.height / 2).toDouble();
  }

  /*
   *  We only want to draw faces that are pointing towards the camera.  We can do 
   *  this by calculating the dot product of both and the angle between them.
   *  https://en.wikipedia.org/wiki/Dot_product.
   */
  bool _shouldDrawFace(Vector3 p1, Vector3 p2, Vector3 p3) {
    var normalVector = Utils.normalVector3(p1, p2, p3);
    var dotProduct = normalVector.dot(camera);
    double vectorLengths = normalVector.length * camera.length;
    double angleBetween = dotProduct / vectorLengths;
    return angleBetween > 0 || true;
  }

  /*
   *  We use a 4x4 matrix to perform our rotation, translation and scaling in
   *  a single pass.
   *  https://www.euclideanspace.com/maths/geometry/affine/matrix4x4/index.htm
   */
  Vector3 _calcVertex(Vector3 vertex) {
    var trans = Matrix.Matrix4.translationValues(_viewPortX, _viewPortY, 1);
    trans.scale(_zoom, -_zoom);
    trans.rotateX(Utils.degreeToRadian(angleX));
    trans.rotateY(Utils.degreeToRadian(angleY));
    trans.rotateZ(Utils.degreeToRadian(angleZ));
    return trans.transform3(vertex);
  }

  /*
   *  Calculate the lighting and paint the polygon on the canvas.
   */
  void _drawFace(Canvas canvas, Vector3 v1, Vector3 v2, Vector3 v3) {
    // Calculate the surface normal
    var normalVector = Utils.normalVector3(v1, v2, v3);

    // Calculate the lighting
    Vector3 normalizedLight = Vector3.copy(light).normalized();
    var jnv = Vector3.copy(normalVector).normalized();
    var normal = Utils.scalarMultiplication(jnv, normalizedLight);
    var brightness = (normal.clamp(0.0, 1.0) * 255).round();

    // Assign a lighting color
    var paint = Paint();
    paint.color = Color.fromARGB(255, brightness, brightness, brightness);
    paint.style = PaintingStyle.fill;

    // Paint the face
    var path = Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v1.x, v1.y);
    path.close();
    canvas.drawPath(path, paint);
  }

  /*
   *  Override the paint method.  Rotate the verticies, remove the backfaces, sort
   *  and finally render our 3D model.
   */
  @override
  void paint(Canvas canvas, Size size) {
    model = Model();

    if (object != null) {
      model.loadFromString(object);
    }

    // Rotate and translate the vertices
    List<Vector3> vertices = []..addAll(model.vertices);
    for (int i = 0; i < vertices.length; i++) {
      vertices[i] = _calcVertex(vertices[i]);
    }

    // Backface removal
    var faces = List<List<int>>();
    for (var i = 0; i < model.faces.length; i++) {
      var face = model.faces[i];
      if (_shouldDrawFace(vertices[face[0] - 1], vertices[face[1] - 1],
          vertices[face[2] - 1])) {
        faces.add(face);
      }
    }

    // Sort
    var sorted = List<Map<String, dynamic>>();
    for (var i = 0; i < faces.length; i++) {
      var face = faces[i];
      sorted.add({
        "index": i,
        "order": Utils.zIndex(
          vertices[face[0] - 1],
          vertices[face[1] - 1],
          vertices[face[2] - 1],
        )
      });
    }
    sorted.sort((Map a, Map b) => a["order"].compareTo(b["order"]));

    // Render
    for (int i = 0; i < sorted.length; i++) {
      var face = faces[sorted[i]["index"]];
      _drawFace(canvas, 
          vertices[face[0] - 1], 
          vertices[face[1] - 1],
          vertices[face[2] - 1]);
    }
  }

  /*
   *  We only want to repaint the canvas when the scene has changed.
   */
  @override
  bool shouldRepaint(_ObjectPainter old) {
    return true;
  }
}
