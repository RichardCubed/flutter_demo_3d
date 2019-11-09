import 'dart:core';
import 'package:flutter/widgets.dart';

/*
 *  A very simple Wavefront .MTL parser, that only parses the diffuse
 *  color values.
 *  https://en.wikipedia.org/wiki/Wavefront_.obj_file
 */
class Materials {

  Map<String, Color> colors;

  Materials() {
    colors = Map<String, Color>();
  }

  /*
   *  Parses the object from a string.
   */
  void loadFromString(String string) {
    List<String> lines = string.split("\n");
    lines.forEach((line) {
      // Parse a material
      if (line.startsWith("newmtl ")) {
      }
    });
  }
}
