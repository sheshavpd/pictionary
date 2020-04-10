import 'dart:convert';

import 'package:flutter/material.dart';

Map<String, dynamic> getJsonFromJWT(String token)
{
  final parts = token.split('.');
  if(parts.length != 3)
    throw Exception("Invalid token");

  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final payloadMap = json.decode(payload);
  if(payloadMap is! Map<String, dynamic>)
    throw Exception('Invalid payload');
  return payloadMap;
}

Color hslRelativeColor({double h = 0.0, s = 0.0, l = 0.0, Color color}) {
  final hslColor = HSLColor.fromColor(color);
  h = (hslColor.hue + h).clamp(0.0, 360.0);
  s = (hslColor.saturation + s).clamp(0.0, 1.0);
  l = (hslColor.lightness + l).clamp(0.0, 1.0);
  return HSLColor.fromAHSL(hslColor.alpha, h, s, l).toColor();
}
