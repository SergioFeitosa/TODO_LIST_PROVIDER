import 'package:flutter/material.dart';

const Color _buttonColor = Colors.green;

extension ThemeExtensions on BuildContext {
  Color get primaryColor => const Color.fromRGBO(255, 105, 180, 1);
  Color get primaryColorLight => const Color.fromARGB(255, 253, 199, 226);
  Color get buttonColor => _buttonColor;
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get titleStyle => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(255, 105, 180, 1),
      );
}
