import 'package:bookstore/common/theme/light_color_scheme.dart';
import 'package:flutter/material.dart';

import 'light_text_theme.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  primaryColor: lightColorScheme.primary,
  textTheme: lightTextTheme,
  fontFamily: 'Segoe',
  iconTheme: IconThemeData(color: Colors.grey[600]),
);
