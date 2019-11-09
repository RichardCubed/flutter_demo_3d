import 'dart:core';
import 'package:vector_math/vector_math.dart';

/*
 *  A very simple Wavefront .OBJ parser.
 *  https://en.wikipedia.org/wiki/Wavefront_.obj_file
 */
class Model {
  List<Vector3> vertices;
  List<Vector3> normals;
  List<List<int>> faces;

  Model() {
    vertices = List<Vector3>();
    normals = List<Vector3>();
    faces = List<List<int>>();
  }

  /*
   *  Parses the object from a string.
   */
  void loadFromString(String string) {
    List<String> lines = string.split("\n");
    lines.forEach((line) {
      // Parse a vertex
      if (line.startsWith("v ")) {
        var values = line.substring(2).split(" ");
        vertices.add(Vector3(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // Parse a normal
      else if (line.startsWith("vn ")) {
        var values = line.substring(3).split(" ");
        normals.add(Vector3(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // Parse a face
      else if (line.startsWith("f ")) {
        var values = line.substring(2).split(" ");
        faces.add(List.from([
          int.parse(values[0].split("/")[0]),
          int.parse(values[1].split("/")[0]),
          int.parse(values[2].split("/")[0]),
        ]));
      }
    });
  }
}
