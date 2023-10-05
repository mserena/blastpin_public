import 'package:flutter/material.dart';

Widget createTopBarElementImage({required String path, required double width, required double height})
{
  return FittedBox(
    alignment: Alignment.centerLeft,
    fit: BoxFit.scaleDown,
    child: Image.asset(
      path,
      width: width,
      height: height,
    ),
  );
}