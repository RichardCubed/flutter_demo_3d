import 'dart:core';
import 'dart:math' as Math;

import 'package:vector_math/vector_math.dart';

/*
 * Static helper functions for a few extra operations.
 */
class Utils {
  /*
   *  Calculate the surface normal.
   *  https://www.khronos.org/opengl/wiki/Calculating_a_Surface_Normal
   */
  static Vector3 normalVector3(Vector3 v1, Vector3 v2, Vector3 v3) {
    Vector3 s1 = Vector3.copy(v2);
    s1.sub(v1);
    Vector3 s3 = Vector3.copy(v2);
    s3.sub(v3);

    return Vector3(
      (s1.y * s3.z) - (s1.z * s3.y),
      (s1.z * s3.x) - (s1.x * s3.z),
      (s1.x * s3.y) - (s1.y * s3.x),
    );
  }

  /*
   *  Multiple one vector by another.
   *  https://en.wikipedia.org/wiki/Scalar_multiplication
   */
  static double scalarMultiplication(Vector3 v1, Vector3 v2) {
    return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
  }

  /*
   *  Radians make it possible to relate a linear measure and an angle measure.
   *  https://teachingcalculus.com/2012/10/12/951/
   */
  static double degreeToRadian(double degree) {
    return degree * (Math.pi / 180.0);
  }

  /*
   *  Calulate the avarage z distance of a face.  Used during sorting
   *  and rendering to draw faces in order from back to front.
   */
  static double zIndex(Vector3 p1, Vector3 p2, Vector3 p3) {
    return (p1.z + p2.z + p3.z) / 3;
  }
}
