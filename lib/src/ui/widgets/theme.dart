// Copyright 2024 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

//
// Flutter has a color profile issue so colors will look different
// on Apple devices.
// https://github.com/flutter/flutter/issues/55092
// https://github.com/flutter/flutter/issues/39113
//

extension LKColors on Colors {
  static const lkLightBlue = Color(0xFF8AB4FF);
  static const lkBlue = Color(0xFF5A8BFF);
  static const lkDarkBlue = Color(0xFF00153C);
}

class LiveKitTheme {
  //
  final bgColor = Colors.black;
  final textColor = Colors.white;
  final cardColor = LKColors.lkDarkBlue;
  final accentColor = LKColors.lkBlue;

  ThemeData buildThemeData(BuildContext ctx) => ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: cardColor,
        ),
        cardColor: cardColor,
        scaffoldBackgroundColor: bgColor,
        canvasColor: bgColor,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle:
                WidgetStateProperty.all<TextStyle>(GoogleFonts.montserrat(
              fontSize: 15,
            )),
            padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 20, horizontal: 25)),
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            // backgroundColor: WidgetStateProperty.all<Color>(accentColor),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return accentColor.withValues(alpha: 0.5);
              }
              return accentColor;
            }),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.all(accentColor),
        ),
        switchTheme: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentColor;
            }
            return accentColor.withValues(alpha: 0.3);
          }),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white.withValues(alpha: 0.3);
          }),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(ctx).textTheme,
        ).apply(
          displayColor: textColor,
          bodyColor: textColor,
          decorationColor: textColor,
        ),
        hintColor: Colors.red,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: LKColors.lkBlue,
          ),
          hintStyle: TextStyle(
            color: LKColors.lkBlue.withValues(alpha: 0.5),
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: bgColor,
        ),
      );
}
