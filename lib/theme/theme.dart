import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Colors.white,
    primary: Color(0xff18C063),
    scrim: Colors.orange,
    outline: Colors.blue,
    inversePrimary: Colors.black,
    surface: Color(0xff596C7B),
    secondary: Colors.black54,
    tertiary: Color(0xff596C7B),
    onSecondary: Colors.black45,
    onSurface: Colors.black12
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Color(0xff11F0C2),
    scrim: Color(0xffFFE083),
    outline: Color(0xff00BBFE),
    inversePrimary: Colors.white,
    surface: Color(0xff596C7B),//7B90A1
    secondary: Colors.grey,
    tertiary: Color(0xff596C7B),
    onSecondary: Colors.white,
    onSurface: Colors.transparent
  ),
);
